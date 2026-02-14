import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Get Azure OpenAI configuration from environment variables
const AZURE_OPENAI_ENDPOINT = Deno.env.get('AZURE_OPENAI_ENDPOINT') ?? ''
const AZURE_OPENAI_API_KEY = Deno.env.get('AZURE_OPENAI_API_KEY') ?? ''
const DEPLOYMENT = Deno.env.get('AZURE_OPENAI_DEPLOYMENT') ?? 'gpt-5.2-chat'
const API_VERSION = Deno.env.get('AZURE_OPENAI_API_VERSION') ?? '2024-04-01-preview'

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    
    // Optional JWT verification (only if Authorization header is present)
    const authHeader = req.headers.get('Authorization')
    if (authHeader) {
      const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? ''
      
      const supabaseAuthClient = createClient(supabaseUrl, supabaseAnonKey, {
        global: {
          headers: { Authorization: authHeader }
        }
      })

      // Verify the user is authenticated
      const { data: { user }, error: authError } = await supabaseAuthClient.auth.getUser()
      
      if (authError || !user) {
        return new Response(
          JSON.stringify({ success: false, error: 'Unauthorized: Invalid or expired token' }),
          { 
            status: 401,
            headers: { 
              'Content-Type': 'application/json',
              ...corsHeaders
            } 
          }
        )
      }
    }

    const { patientId, therapistId } = await req.json()

    if (!patientId || !therapistId) {
      return new Response(
        JSON.stringify({ success: false, error: 'patientId and therapistId are required' }),
        { 
          status: 400,
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders
          } 
        }
      )
    }

    // Validate Azure OpenAI configuration
    if (!AZURE_OPENAI_ENDPOINT || !AZURE_OPENAI_API_KEY) {
      return new Response(
        JSON.stringify({ success: false, error: 'Azure OpenAI configuration is missing. Please set AZURE_OPENAI_ENDPOINT and AZURE_OPENAI_API_KEY environment variables.' }),
        { 
          status: 500,
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders
          } 
        }
      )
    }

    // Initialize Supabase client with service role for database operations
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    if (!serviceRoleKey) {
      throw new Error('SUPABASE_SERVICE_ROLE_KEY environment variable is not set')
    }
    
    const supabaseClient = createClient(supabaseUrl, serviceRoleKey)

    // Fetch recent therapy goals (last 30 days)
    const thirtyDaysAgo = new Date()
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)
    
    const { data: therapyGoals, error: goalsError } = await supabaseClient
      .from('therapy_goal')
      .select('goals, observations, regressions, activities, performed_on, goal_achievement_status')
      .eq('patient_id', patientId)
      .eq('therapist_id', therapistId)
      .gte('performed_on', thirtyDaysAgo.toISOString())
      .order('performed_on', { ascending: false })
      .limit(20)

    if (goalsError) {
      console.error('Error fetching therapy goals:', goalsError)
      throw goalsError
    }

    // Fetch daily activity completion data (last 30 days)
    const { data: activityLogs, error: logsError } = await supabaseClient
      .from('daily_activity_logs')
      .select('date, activity_items, parent_notes')
      .eq('patient_id', patientId)
      .gte('date', thirtyDaysAgo.toISOString())
      .order('date', { ascending: false })
      .limit(30)

    if (logsError) {
      console.error('Error fetching activity logs:', logsError)
      throw logsError
    }

    // Calculate activity completion rates
    const completionData = (activityLogs || []).map((log: any) => {
      const items = log.activity_items || []
      const completed = items.filter((item: any) => item.is_completed).length
      const total = items.length
      return {
        date: log.date,
        completionRate: total > 0 ? (completed / total) * 100 : 0,
        totalActivities: total,
        completedActivities: completed
      }
    })

    // Prepare data for AI analysis
    const analysisData = {
      therapyGoals: therapyGoals || [],
      activityCompletion: completionData,
      totalSessions: therapyGoals?.length || 0,
      dateRange: {
        start: thirtyDaysAgo.toISOString(),
        end: new Date().toISOString()
      }
    }

    // Call Azure OpenAI
    const response = await fetch(
      `${AZURE_OPENAI_ENDPOINT}openai/deployments/${DEPLOYMENT}/chat/completions?api-version=${API_VERSION}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'api-key': AZURE_OPENAI_API_KEY,
        },
        body: JSON.stringify({
          messages: [
            {
              role: "system",
              content: `You are a developmental milestones analyst for children with special needs. 
              Analyze therapy session data and daily activity completion to identify developmental milestones, 
              progress patterns, and areas of concern. Provide insights in a structured, professional format.`
            },
            {
              role: "user",
              content: `Analyze the following therapy data and provide developmental milestone insights:

Therapy Goals Data (${analysisData.totalSessions} sessions):
${JSON.stringify(analysisData.therapyGoals, null, 2)}

Daily Activity Completion:
${JSON.stringify(analysisData.activityCompletion, null, 2)}

Please provide:
1. Key developmental milestones achieved (if any patterns detected)
2. Progress trends (improving, stable, or concerning areas)
3. Notable achievements from therapy goals
4. Activity completion patterns and their significance
5. Areas that may need attention
6. Overall developmental progress summary

Format the response as a JSON object with this structure:
{
  "milestones": [
    {
      "title": "Milestone name",
      "category": "motor|cognitive|social|communication|behavioral|self_care",
      "status": "achieved|in_progress|regressed",
      "description": "Brief description",
      "evidence": "Supporting evidence from data"
    }
  ],
  "progressSummary": "Overall progress summary",
  "trends": {
    "improving": ["list of improving areas"],
    "stable": ["list of stable areas"],
    "concerning": ["list of areas needing attention"]
  },
  "recommendations": ["actionable recommendations"]
}`
            }
          ],
          max_completion_tokens: 2000,
          temperature: 1,
          model: DEPLOYMENT
        })
      }
    )

    if (!response.ok) {
      const errorText = await response.text()
      console.error('Azure OpenAI API error:', response.status, errorText)
      throw new Error(`Azure OpenAI API error: ${response.statusText}`)
    }

    const aiResponse = await response.json()
    const content = aiResponse.choices[0]?.message?.content || ""

    // Try to parse JSON from response
    let milestonesData
    try {
      // Extract JSON from markdown code blocks if present
      const jsonMatch = content.match(/```json\n([\s\S]*?)\n```/) || content.match(/```\n([\s\S]*?)\n```/)
      const jsonString = jsonMatch ? jsonMatch[1] : content
      milestonesData = JSON.parse(jsonString)
    } catch (parseError) {
      console.error('Failed to parse AI response as JSON:', parseError)
      // If parsing fails, create structured response
      milestonesData = {
        milestones: [],
        progressSummary: content || "Unable to analyze milestones at this time. Please ensure there is sufficient therapy data.",
        trends: {
          improving: [],
          stable: [],
          concerning: []
        },
        recommendations: []
      }
    }

    return new Response(
      JSON.stringify({ success: true, data: milestonesData }),
      { 
        headers: { 
          'Content-Type': 'application/json',
          ...corsHeaders
        } 
      }
    )

  } catch (error) {
    console.error('Error in analyze-milestones function:', error)
    console.error('Error stack:', error.stack)
    console.error('Error details:', JSON.stringify(error, Object.getOwnPropertyNames(error)))
    
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message || 'Internal server error',
        details: error.stack || 'No stack trace available'
      }),
      { 
        status: 500,
        headers: { 
          'Content-Type': 'application/json',
          ...corsHeaders
        } 
      }
    )
  }
})
