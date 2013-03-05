public class SendNewCaseMMS {
    
    @future (callout=true)
    public static void sendMMSNotification(Set<Id> caseIds){
        List<Case> cases = [select caseNumber, Account.BillingStreet, 
                                   TYPEOF Owner when User then MobilePhone end 
                            from Case where id in :caseIds];
        AttClientCredentialsAuthorization auth = new AttClientCredentialsAuthorization(
            											ServiceConstants.ScopeType.MMS);
        for (Case c : cases){
            if (c.Owner instanceof User && ((User)c.Owner).MobilePhone != null){
                AttMMSOutbox mmsOutbox = new AttMMSOutbox(auth);
                AttMMS mms  = new AttMMS();
                String unformattedNo = ((User)c.Owner).MobilePhone.deleteWhitespace().remove('(').remove(')').remove('-');
                mms.phoneNumber = unformattedNo;
                mms.subject = 'New Case #'+c.caseNumber+ ' has been assigned to you';
                
                if (c.Account != null && c.Account.BillingStreet != null){
                    Http httpProtocol = new Http();
                    HttpRequest request = new HttpRequest();
                    String googleMapURL = 	'http://maps.googleapis.com/maps/api/staticmap'+
                                            '?size=300x300&sensor=false&markers=size:mid%7Ccolor:red%7C'+
                                            EncodingUtil.urlEncode(c.Account.BillingStreet, 'UTF-8');
                    request.setEndPoint(googleMapURL);
                    request.setMethod('GET');
                    HttpResponse res = httpProtocol.send(request);
                    
                    AttAttachment attach = new AttAttachment(res.getBodyAsBlob(), 'map.png', 'image/png');
                    mms.attachments.add(attach);
                }
                
                try {
                    mmsOutbox.sendMessage(mms);
                } catch (AttException ex) {
                    System.debug('Error sending MMS:'+ex);
                }
            }
        }
    }
}