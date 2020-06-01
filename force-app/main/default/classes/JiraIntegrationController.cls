public class JiraIntegrationController {

  public List<JiraIssue__c> supportIssues {get;set;}
  public String issueKey{get;set;}
  string searchKey = '';
  public string username;
  public string password;

  public List<JiraIssue__c> getSupportIssues(){
      return supportIssues;
  }

  public integer startAt = 0;
  public integer maxResults= 10;

public void sameAsJIC(){
		
    		String username = 'omkarde@cybage.com';
            String password = 'atlassian#123';
    		Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://iambatman.atlassian.net/rest/api/2/issue/MS-13');
            req.setMethod('GET');
  			Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + 'b21rYXJkZUBjeWJhZ2UuY29tOmF0bGFzc2lhbiMxMjM=';
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', authorizationHeader);
    String jh = null;
        
        
    	
       /* req.setEndpoint('https://iambatman.atlassian.net/rest/api/2/search?jql='+
                       // '&os_username=' + username + 
                        //'&os_password=' + password +
                        //'&fields=' + fields + 
                        '&startAt='+ startAt +
                        '&maxResults='+maxResults);*/
    	//req.setEndpoint('https://iambatman.atlassian.net/rest/api/2/search');
        //req.setMethod('GET');

		//https://iambatman.atlassian.net/rest/api/2/search?jql=&os_username='omkarde@cybage.com'&os_password='atlassian#123'&startAt='0'&maxResults='10'
		
        HttpResponse res = http.send(req);

        // Log the JSON content
        System.debug('JSON Response: ' + res.getBody());

        String JSONContent = res.getBody();
        supportIssues = new List<JiraIssue__c>();
    	System.debug(JSONContent);
		
        JSONParser parserJira = JSON.createParser(JSONContent);
        //while (parserJira.nextToken() != null) 
        //{
        // Start at the array of issues.
         //   if (parserJira.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parserJira.nextToken() != null) {
                    if ((parserJira .getCurrentToken() == JSONToken.START_OBJECT)){ 
                        issue jiraIssue = (issue)parserJira.readValueAs(issue.class);
                        System.debug(jiraIssue.key);
                    }

                }
          //  }

            
        //}

    
    
    
   /* JSONParser parserJira = JSON.createParser(JSONContent);
    while (parserJira.nextToken() != null) {
        if (parserJira.getCurrentToken() == JSONToken.START_ARRAY) {
            //System.debug('print1');
            while (parserJira.nextToken() != null) {
                if ((parserJira .getCurrentToken() == JSONToken.FIELD_NAME) && parserJira.getText() == 'key') {
                    //issue jiraIssue = (issue)parserJira.readValueAs(issue.class);
 					parserJira.nextToken();
                    System.debug(parserJira.getText());
                    parserJira.skipChildren();
                }
            }
        }
    }
    System.debug(JSONContent);
    */
	
  /*
    supportIssues = new List<JiraIssue__c>();
    	JSONParser parserJira = JSON.createParser(JSONContent);
    while (parserJira.nextToken() != null) {
        if (parserJira.getCurrentToken() == JSONToken.START_ARRAY) {
            while (parserJira.nextToken() != null) {
                issue jiraIssue = (issue)parserJira.readValueAs(issue.class);
                //JiraIssue__c supportIssue = new JiraIssue__c();
                //supportIssue.Issue_Key__c = jiraIssue.key;
                //supportIssue.Summary__c = jiraIssue.fields.summary;
                //supportIssues.add(supportIssue);
            }
        }        
    }
*/
    
    
    
    
  }

  public JiraIntegrationController() {
        //Jira_Adapter__c[] jiraUsers = [SELECT Username__c, Password__c FROM Jira_Adapter__c];
        sameAsJIC();
      
  }

   public class issue{
      public string expand;
      public fields fields;
      public string id;
      public string key;
      public string self;
}
public class Status {
    public String self;
    public String description;
    public String iconUrl;
    public String name;
    public String id;
    public StatusCategory statusCategory;
}

    
    


public class Comment {
    public Integer startAt;
    public Integer maxResults;
    public Integer total;
    public List<Comments> comments;
}

public String expand;
public String id;
public String self;
public String key;
public Fields fields;

    public class Assignee {
    public String self;
    public String name;
    public String key;
    public String emailAddress;
    public AvatarUrls avatarUrls;
    public String displayName;
    public Boolean active;
    public String timeZone;
}
public class links {
    public String self;
}

public class Priority {
    public String self;
    public String iconUrl;
    public String name;
    public String id;
}

public class Comments {
    public String self;
    public String id;
    public Assignee author;
    public String body;
    public Assignee updateAuthor;
    public String created;
    public String updated;
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

public class StartTime {
    public String iso8601;
    public String friendly;
    public Long epochMillis;
}

public class Customfield_10025 {
    public Integer id;
    public String name;
    public links links;
    public List<FixVersions> completedCycles;
    public OngoingCycle ongoingCycle;
}

public class Customfield_10026 {
    public String errorMessage;
}

public class Customfield_10015 {
    public String errorMessage;
    public I18nErrorMessage i18nErrorMessage;
}

public class OngoingCycle {
    public StartTime startTime;
    public StartTime breachTime;
    public Boolean breached;
    public Boolean paused;
    public Boolean withinCalendarHours;
    public GoalDuration goalDuration;
    public GoalDuration elapsedTime;
    public GoalDuration remainingTime;
}

public class Project {
    public String self;
    public String id;
    public String key;
    public String name;
    public AvatarUrls avatarUrls;
}

public class StatusCategory {
    public String self;
    public Integer id;
    public String key;
    public String colorName;
    public String name;
}

public class Worklog {
    public Integer startAt;
    public Integer maxResults;
    public Integer total;
    public List<FixVersions> worklogs;
}

public class Fields {
    public Issuetype issuetype;
    public String timespent;
    public Project project;
    public List<FixVersions> fixVersions;
    public String aggregatetimespent;
    public Resolution resolution;
    public Date resolutiondate;
    public Integer workratio;
    public String lastViewed;
    public Watches watches;
    public String created;
    public String customfield_10020;
    public String customfield_10021;
    public Priority priority;
    public Customfield_10025 customfield_10025;
    public List<FixVersions> labels;
    public Customfield_10026 customfield_10026;
    public List<FixVersions> customfield_10016;
    public String customfield_10017;
    public String customfield_10018;
    public String customfield_10019;
    public Integer timeestimate;
    public Integer aggregatetimeoriginalestimate;
    public List<FixVersions> versions;
    public List<FixVersions> issuelinks;
    public Assignee assignee;
    public String updated;
    public Status status;
    public List<FixVersions> components;
    public String timeoriginalestimate;
    public String description;
    public String customfield_10010;
    public String customfield_10011;
    public String customfield_10012;
    public String customfield_10013;
    public String customfield_10014;
    public FixVersions timetracking;
    public Customfield_10015 customfield_10015;
    public String customfield_10005;
    public String customfield_10006;
    public String customfield_10007;
    public String customfield_10008;
    public List<FixVersions> attachment;
    public String customfield_10009;
    public Integer aggregatetimeestimate;
    public String summary;
    public Assignee creator;
    public List<FixVersions> subtasks;
    public Assignee reporter;
    public String customfield_10000;
    public Aggregateprogress aggregateprogress;
    public String customfield_10001;
    public String customfield_10002;
    public String customfield_10003;
    public String customfield_10004;
    public String environment;
    public Date duedate;
    public Aggregateprogress progress;
    public Comment comment;
    public Votes votes;
    public Worklog worklog;
}

public class FixVersions {
}

public class I18nErrorMessage {
    public String i18nKey;
    public List<FixVersions> parameters;
}

public class Issuetype {
    public String self;
    public String id;
    public String description;
    public String iconUrl;
    public String name;
    public Boolean subtask;
}

public class AvatarUrls {
    public String fortyEight;
    public String twentyFour;
    public String sixteen;
    public String thirtyTwo;
}

public class GoalDuration {
    public Integer millis;
    public String friendly;
}

public class Votes {
    public String self;
    public Integer votes;
    public Boolean hasVoted;
}     
	public class Resolution {
		public String self;
		public String id;
		public String description;
		public String name;
	}
}