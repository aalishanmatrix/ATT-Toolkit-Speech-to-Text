public with sharing class CaseDemoController {

    public static Map<String, AttSpeech.FileType> audioTypeMap = new Map<String, AttSpeech.FileType> {       
        'audio/wav' => AttSpeech.FileType.WAV,       
        'audio/amr' => AttSpeech.FileType.AMR,       
        'audio/amr-wb' => AttSpeech.FileType.AMRWB,
        'audio/x-wav' => AttSpeech.FileType.XWAV,
        'audio/x-speex' => AttSpeech.FileType.XSPEEX
    };
            
    public class SearchResult {
        public List<Case> cases;
        public String resultText;
        public SearchResult() {
        }
    }

    public Component.Apex.IncludeScript getCordovaJS() {
        String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
        Component.Apex.IncludeScript jsScript; 
        if (userAgent.contains('iPhone') || userAgent.contains('iPad')){
            jsScript = new Component.Apex.IncludeScript();
            jsScript.expressions.value = '{!URLFOR($Resource.Cordova_2_3_0_iOS)}';
        }else if (userAgent.contains('Android')){
            jsScript = new Component.Apex.IncludeScript();
            jsScript.expressions.value = '{!URLFOR($Resource.Cordova_2_3_0_Android)}';
        }        
        return jsScript;
    }
    
    @RemoteAction
    public static List<Case> getCaseRecs(){
        return [select Id, Account.Name, Account.BillingStreet, caseNumber, 
                status, priority, subject, description from Case 
                where ownerId = :UserInfo.getUserID()
                order by createdDate desc];
    }
    
    @RemoteAction
    public static SearchResult searchCases(String speechInput, String mimeType){
        System.debug('Size is:'+speechInput.length());
        SearchResult sr = new SearchResult();
        
        try {
            if (String.isBlank(mimeType)) {               
            	throw new AttException('Content-Type not specified.');
            }
            AttSpeech speech = new AttSpeech(
                							new AttClientCredentialsAuthorization(
                                                ServiceConstants.ScopeType.SPEECH));
            
            speech.speechContext = AttSpeech.SpeechContext.GENERIC;
            speech.fileType = audioTypeMap.get(mimeType);              
            speech.fileBlob = EncodingUtil.base64Decode(speechInput);
            
            AttSpeechResult response = speech.convert();
            System.debug('Response is:'+response);
            
            AttSpeechResult.Recognition recogn = response.Recognition;
            
            if (recogn.NBest == null) {
                throw new AttException('Voice data empty');
            }
            
            sr.resultText = recogn.NBest[0].hypothesis;
                
        } catch(AttException e) {
            return null;
        } 
        
        String searchTerm = '%'+String.escapeSingleQuotes(sr.resultText)+'%';
		sr.cases = [select Id, Account.Name, Account.BillingStreet, 
                            caseNumber, status, priority, subject, description 
                            from Case where Account.Name like :searchTerm];
        return sr;
    }
}