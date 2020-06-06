public class GanttChartController {
    class TaskWrapperClass {
        @auraEnabled public String id;
        @auraEnabled public String taskName;
        @auraEnabled public String color;
        @auraEnabled public Decimal left;
        @auraEnabled public Decimal right;
        @auraEnabled public Date startDate;
        @auraEnabled public Date endDate;
        @auraEnabled public String recordTypeName;
    }
    
    public class ProjectWrapperClass {
        @auraEnabled public String id;
        @auraEnabled public String projectName;
        @auraEnabled public List<TaskWrapperClass> taskDataList;
    }
    
    @auraEnabled
    public static List<ProjectWrapperClass> getGanttData(String recordId, String startDateStr, String endDateStr, Integer slotSize) {
        Date startDate = DateTime.newInstance(Long.valueOf(startDateStr)).date();
        Date endDate = DateTime.newInstance(Long.valueOf(endDateStr)).date();
        List<ProjectWrapperClass> returnData = new List<ProjectWrapperClass>();
        system.debug(startDate);
        system.debug(endDate);
        List<Task__c> taskList = [Select Id, name, start_date__c, end_date__c, project__r.recordType.name, project__c
                                  From Task__c 
                                  Where start_date__c <= :endDate AND End_Date__c >= :startDate
                                  Order by project__c
                                 ];
        Map<Id, List<TaskWrapperClass>> projectToTasksMap = new Map<Id, List<TaskWrapperClass>>();
        
        //Integer slotSize = 7;
        
        for (Task__c task : taskList) {
            TaskWrapperClass taskData = new TaskWrapperClass();
            taskData.id = task.Id;
            taskData.taskName = task.name;
            taskData.startDate = task.start_date__c;
            taskData.endDate = task.end_date__c;
            taskData.recordTypeName = task.project__r.recordType.name;
            //taskData.projectName = task.
            Decimal left = Decimal.valueOf(startDate.daysBetween(task.Start_Date__c)) / slotSize;
            taskData.left = left.round(System.RoundingMode.FLOOR);
            
            Decimal right = Decimal.valueOf(startDate.daysBetween(task.End_Date__c)) / slotSize;
            taskData.right = right.round(System.RoundingMode.FLOOR);
            
            if (projectToTasksMap.containsKey(task.project__c)) {
                projectToTasksMap.get(task.project__c).add(taskData);
            } else {
                projectToTasksMap.put(task.project__c, new List<TaskWrapperClass>{taskData});
            }
        }
        
        for (Id id : projectToTasksMap.keySet()) {
            ProjectWrapperClass projectdata = new ProjectWrapperClass();
            projectdata.Id = id;
            projectdata.projectName = projectToTasksMap.get(Id)[0].recordTypeName;
            projectdata.taskDataList = projectToTasksMap.get(Id);
            
            returnData.add(projectdata);
        }
        
        return returnData;
    }
}