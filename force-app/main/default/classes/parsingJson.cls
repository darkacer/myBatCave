public class parsingJson {
    public List<JiraIssue__c> supportIssues {get;set;}
	 public List<JiraIssue__c> getSupportIssues(){
      return supportIssues;
  }
    public void parseMyJson() {
        

        StaticResource srObject = [select id,body from StaticResource Where Name = 'jsonResponse2'];
		String JSONContent = srObject.body.toString();
        System.debug(JSONContent);
        //while (parserJira.nextToken() != null) 
        //{
        // Start at the array of issues.
         //   if (parserJira.getCurrentToken() == JSONToken.START_ARRAY) {
         //   
         Map <String, String> myMap = new Map<String,String>();
        JSONParser parserJira = JSON.createParser(JSONContent);
        /*
        while (parserJira.nextToken() != null) {
                    if ((parserJira .getCurrentToken() == JSONToken.START_OBJECT) ){ 
                        //issue jiraIssue = (issue)parserJira.readValueAs(issue.class);
                        //System.debug(jiraIssue.key);
                      parserJira.nextToken();
                      if ()
                      System.debug(parserJira.getText());
                    }

                }
        
        while (parserJira.nextToken() != null) { 
            if (parserJira.getText() == 'fields') {
                if(parserJira.nextToken() == JSONToken.START_OBJECT) {
                    //
                    while(parserJira.nextToken() != null) {
                        if (parserJira.getText() == 'created') {
                            parserJira.nextToken();
                             System.debug(parserJira.getText());
                        }
                       
                    }
                        
                }
            }
        }  
       
        
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSONContent);
        System.debug(m.get('key'));
        Map<String, Object> feild = (Map<String, Object>)m.get('fields');
        System.debug(feild.get('issuetype'));

          //  }
		
*/            
        //}
        //
        //
        //
        //	JSONParser parserJira = JSON.createParser(JSONContent);
        supportIssues = new List<JiraIssue__c>();
        while (parserJira.nextToken() != null) 
        {

            // Start at the array of issues.
            if (parserJira.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parserJira.nextToken() != null) {
                    if ((parserJira .getCurrentToken() == JSONToken.START_OBJECT)){ 
                        issue jiraIssue = (issue)parserJira.readValueAs(issue.class);
                        JiraIssue__c supportIssue = new JiraIssue__c();
                        supportIssue.Issue_Key__c = jiraIssue.key;
                        supportIssue.Summary__c = jiraIssue.fields.summary;
                        supportIssues.add(supportIssue);
                    }

                }
            }
        }
        
        System.debug(supportIssues.size());
    
    }
    
    
    
    
    
    
    
    
     public class issue{
      public string expand;
      public fields fields;
      public string id;
      public string key;
      public string self;
}


public String expand;
public String id;
public String self;
public String key;
public Fields fields;

   public class Status {
		public String self;
		public String description;
		public String iconUrl;
		public String name;
		public String id;
		public StatusCategory statusCategory;
	}

	public class Assignee {
		public String self;
		public String name;
		public String key;
		public String accountId;
		public String emailAddress;
		public AvatarUrls avatarUrls;
		public String displayName;
		public Boolean active;
		public String timeZone;
	}

	public class JSON2Apex {
		public String expand;
		public String id;
		public String self;
		public String key;
		public Fields fields;
	}

	public class Priority {
		public String self;
		public String iconUrl;
		public String name;
		public String id;
	}

	public class Aggregateprogress {
		public Integer progress;
		public Integer total;
	}

	public class Watches {
		public String self;
		public Integer watchCount;
		public Boolean isWatching;
	}

	public class Labels {
	}

	public class Project {
		public String self;
		public String id;
		public String key;
		public String name;
		public String projectTypeKey;
		public AvatarUrls avatarUrls;
	}

	public class StatusCategory {
		public String self;
		public Integer id;
		public String key;
		public String colorName;
		public String name;
	}

public class Fields {
		public Issuetype issuetype;
		public Object timespent;
		public Project project;
		public List<FixVersions> fixVersions;
		public Object aggregatetimespent;
		public Object resolution;
		public Object resolutiondate;
		public Integer workratio;
		public Object lastViewed;
		public Watches watches;
		public String created;
		public Object customfield_10020;
		public Object customfield_10021;
		public Object customfield_10022;
		public Object customfield_10023;
		public Priority priority;
		public Object customfield_10024;
		public List<Labels> labels;
		public Object customfield_10017;
		public Object customfield_10018;
		public Object customfield_10019;
		public Object aggregatetimeoriginalestimate;
		public Object timeestimate;
		public List<Labels> versions;
		public List<Labels> issuelinks;
		public Assignee assignee;
		public String updated;
		public Status status;
		public List<Labels> components;
		public Object timeoriginalestimate;
		public String description;
		public List<String> customfield_10010;
		public String customfield_10011;
		public Object customfield_10012;
		public Object customfield_10013;
		public Object security;
		public Object customfield_10008;
		public Object aggregatetimeestimate;
		public Object customfield_10009;
		public String summary;
		public Assignee creator;
		public List<Labels> subtasks;
		public Assignee reporter;
		public Aggregateprogress aggregateprogress;
		public String customfield_10000;
		public Object customfield_10001;
		public Object customfield_10002;
		public Object customfield_10003;
		public Object customfield_10004;
		public Object environment;
		public Object duedate;
		public Aggregateprogress progress;
		public Votes votes;
	}

	public class FixVersions {
		public String self;
		public String id;
		public String name;
		public Boolean archived;
		public Boolean released;
		public String releaseDate;
	}

	public class Issuetype {
		public String self;
		public String id;
		public String description;
		public String iconUrl;
		public String name;
		public Boolean subtask;
		public Integer avatarId;
	}

	public class AvatarUrls {
    public String fortyEight;
    public String twentyFour;
    public String sixteen;
    public String thirtyTwo;
}

	public class Votes {
		public String self;
		public Integer votes;
		public Boolean hasVoted;
	}

}