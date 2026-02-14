import { createClient } from "jsr:@supabase/supabase-js@2";

// DTO Types (inlined for Dashboard deployment)
interface AssessmentDTO {
  name: string;
  description: string;
  category: string;
  cutoff_score: number;
  questions: QuestionDTO[];
}

interface QuestionDTO {
  question_id: string;
  text: string;
  options: OptionDTO[];
}

interface OptionDTO {
  option_id: string;
  text: string;
  score: number;
}

interface AssessmentEvaluationRequestDTO {
  assessment_id: string;
  questions: AssessmentEvaluationQuestionDTO[];
}

interface AssessmentEvaluationQuestionDTO {
  question_id: string;
  answer_id: string;
}

const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!);

/**
 * Supabase Edge Function to evaluate an autism assessment.
 * 
 * This function:
 * 1. Receives a request containing `assessment_id` and `questions` (answered by the user).
 * 2. Fetches the assessment data from the `assessments` table in Supabase.
 * 3. Calculates the total score based on the user's answers.
 * 4. Compares the total score with the assessment's cutoff score.
 * 5. Returns a JSON response indicating whether the user is likely autistic.
 * 
 * @param {Request} req - The HTTP request object containing JSON payload.
 * @returns {Response} - A JSON response with the assessment results.
 */

Deno.serve( async (req) => {
  // CORS headers for all responses
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, accept',
    'Access-Control-Max-Age': '3600',
  };

  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  }

  try {

    const { patient_id, assessment_id, questions } = await req.json();

    const { data, error } = await supabase
      .from("assessments")
      .select("*")
      .eq("id", assessment_id)
      .single();

      if(error) {
        return new Response(
          JSON.stringify({ error: "Internal Server Error" }), 
          { 
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }

      if (!data) {
        return new Response(
          JSON.stringify({ error: "Assessment not found" }), 
          { 
            status: 404,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }

      const answered_questions: AssessmentEvaluationRequestDTO = {
        assessment_id: assessment_id,
        questions: questions.map((q: AssessmentEvaluationQuestionDTO) => ({
          question_id: q.question_id,
          answer_id: q.answer_id,
        }))
      };

      const assessment: AssessmentDTO = {
        name: data.name,
        description: data.description,
        category: data.category,
        cutoff_score: data.cutoff_score,
        questions: data.questions.map((q: QuestionDTO) => ({
          question_id: q.question_id,
          text: q.text,
          options: q.options.map((o: OptionDTO) => ({
            option_id: o.option_id,
            text: o.text,
            score: o.score,
          })),
        })),
      };

      let totalScore = 0;

      for(let i=0;i<answered_questions.questions.length;i++) {
        const question = answered_questions.questions[i];
        const matched_question = assessment.questions.find(q => q.question_id === question.question_id);

        if(!matched_question) {
          continue;
        }

        const answer = matched_question.options.find(o => o.option_id === question.answer_id);

        if(!answer) {
          continue;
        }

        totalScore += answer.score;
      }

      const isAutistic = totalScore >= assessment.cutoff_score;
      
      const responseData = {
        assessment_score: totalScore,
        is_autistic: isAutistic,
        message: isAutistic
          ? "The assessment indicates a likelihood of autism. Further evaluation is recommended."
          : "The assessment does not indicate autism, but professional consultation is advised if needed.",
      };

      await supabase.from('assessment_results')
            .insert({
              'assessment_id': assessment_id,
              'submission': answered_questions,
              'patient_id': patient_id,
              'result': responseData,
            });

      return new Response(
        JSON.stringify(responseData),{
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        },
      );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: "Internal Server Error" }), 
      { 
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
})