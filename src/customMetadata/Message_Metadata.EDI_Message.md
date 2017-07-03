<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>EDI Message</label>
    <protected>false</protected>
    <values>
        <field>Message_Body__c</field>
        <value xsi:type="xsd:string">Hi {!$User.FirstName} {$User.LastName},&lt;p/&gt;&lt;p/&gt;
Based on the Issue Category you’ve selected, &quot;{1},{!Case.Sub_Category_1__c}&quot; we believe that you will receive the best possible service by contacting the EDI Support team directly.&lt;p/&gt;&lt;p/&gt;

For your convenience, the they can be reached in a number of ways:&lt;BR/&gt;
By Phone: (479)273-8888 - option 2&lt;BR/&gt;
&lt;a href=&quot;mailto:edi@wal-mart.com&quot;&gt;By email: edi@wal-mart.com&lt;/a&gt;&lt;p/&gt;

If you’d prefer not to reach out to this team directly and instead submit your case here, please close this dialogue box  by clicking Ok and complete your submission.  Please note that if you choose this option, your case may take longer to be resolved.</value>
    </values>
</CustomMetadata>
