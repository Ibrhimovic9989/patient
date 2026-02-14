import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:therapist/model/model.dart';
import 'package:therapist/presentation/therapy_goals/widgets/therapy_dotted_empty_container.dart';
import 'package:therapist/provider/therapy_provider.dart';

enum TherapyDetailsType {
  goals('Goals'),
  observation('Observation'),
  regression('Regression'),
  activities('Activities');

  final String value;
  const TherapyDetailsType(this.value);

}

class TherapyContainer extends StatelessWidget {
  const TherapyContainer({
    super.key,
    required this.therapyDetailsType,
    required this.therapyInfo,
  });

  final TherapyDetailsType therapyDetailsType;
  final List<TherapyModel> therapyInfo;

  @override
  Widget build(BuildContext context) {
    return therapyInfo.isEmpty ? 
      TherapyDottedEmptyContainer(therapyDetailsType: therapyDetailsType)
      : Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: const Color(0xffC7C8D2),),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            therapyDetailsType.value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xff121417)
            ),
          ),
          const SizedBox(height: 8,),
          const Divider(
            color: Color(0xffE1E2E7),
            height: 1,
          ),
          ...therapyInfo.map(
            (info) {
              // For goals, show achievement status checkboxes
              if (therapyDetailsType == TherapyDetailsType.goals) {
                return Consumer<TherapyProvider>(
                  builder: (context, provider, child) {
                    final currentStatus = provider.goalAchievementStatus[info.id] ?? 'not_started';
                    return Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              info.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff111847),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Achievement status dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: DropdownButton<String>(
                              value: currentStatus,
                              underline: const SizedBox(),
                              isDense: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'not_started',
                                  child: Text('Not Started', style: TextStyle(fontSize: 12)),
                                ),
                                DropdownMenuItem(
                                  value: 'in_progress',
                                  child: Text('In Progress', style: TextStyle(fontSize: 12)),
                                ),
                                DropdownMenuItem(
                                  value: 'achieved',
                                  child: Text('Achieved', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  provider.setGoalAchievementStatus(info.id, value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              
              // For other types, show regular text
              return Container(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  info.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff111847),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}