public class AccountContactEventPublisher {

    public static void publishAccountContactData(
        Set<Id> accountIds,
        Map<Id, List<Opportunity>> accountToOpportunities
    ) {

        try {

            // ------------------------------------
            // Validate Account IDs
            // ------------------------------------

            if (accountIds == null || accountIds.isEmpty()) {

                System.debug(
                    LoggingLevel.ERROR,
                    'AccountContactEventPublisher: Account Ids are empty.'
                );

                return;
            }

            // ------------------------------------
            // Query Accounts + Contacts
            // ------------------------------------

            List<Account> accounts = [
                SELECT
                    Id,
                    Name,
                    BillingStreet,
                    BillingCity,
                    BillingState,
                    BillingCountry,
                    BillingPostalCode,
                    SW_CustomerID__c,
                    Industry,
                    ParentId,
                    Parent.SW_CustomerID__c,
                    (
                        SELECT
                            Id,
                            FirstName,
                            LastName,
                            Email,
                            Phone,
                            Title,
                        	SW_Contact_Type__c,
                        MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
                        FROM Contacts
                    )
                FROM Account
                WHERE Id IN :accountIds
            ];

            // ------------------------------------
            // Create Platform Events
            // ------------------------------------

            List<Create_Account__e> eventsToPublish =
                new List<Create_Account__e>();

            for (Account acc : accounts) {

                // --------------------------------
                // Account Data
                // --------------------------------

                Map<String, Object> accountData =
                    new Map<String, Object>();

                accountData.put('Id', acc.Id);
                accountData.put('Name', acc.Name);

                accountData.put(
                    'BillingStreet',
                    acc.BillingStreet
                );

                accountData.put(
                    'BillingCity',
                    acc.BillingCity
                );

                accountData.put(
                    'BillingState',
                    acc.BillingState
                );

                accountData.put(
                    'BillingCountry',
                    acc.BillingCountry
                );

                accountData.put(
                    'BillingPostalCode',
                    acc.BillingPostalCode
                );

                accountData.put(
                    'SW_CustomerID__c',
                    acc.SW_CustomerID__c
                );

                accountData.put(
                    'Industry',
                    acc.Industry
                );

                accountData.put(
                    'ParentId',
                    acc.ParentId
                );

                if (acc.Parent != null) {

                    accountData.put(
                        'Parent_SW_CustomerID__c',
                        acc.Parent.SW_CustomerID__c
                    );

                } else {

                    accountData.put(
                        'Parent_SW_CustomerID__c',
                        null
                    );
                }

                // --------------------------------
                // Contact Data
                // --------------------------------

                List<Map<String, Object>> contacts =
                    new List<Map<String, Object>>();

                for (Contact con : acc.Contacts) {

                    Map<String, Object> contactData =
                        new Map<String, Object>();
					
					String address = con.MailingStreet + ' ' +
                                     con.MailingCity + ' ' +
                                     con.MailingState + ' ' +
                                     con.MailingPostalCode + ' ' +
                                     con.MailingCountry;

                    
                   /* contactData.put(
                        'Address',
                        address
                    ); */
                    
                    contactData.put(
                        'Mailing Street',
                        con.MailingStreet
                    );
                    
                    contactData.put(
                        'City',
                         con.MailingCity
                    );
                    
                    contactData.put(
                        'State',
                         con.MailingState
                    );
                    
                    contactData.put(
                        'Postal Code',
                         con.MailingPostalCode
                    );
                    
                    contactData.put(
                        'Country',
                         con.MailingCountry
                    );
                    
                    contactData.put(
                        'Id',
                        con.Id
                    );

                    contactData.put(
                        'FirstName',
                        con.FirstName
                    );

                    contactData.put(
                        'LastName',
                        con.LastName
                    );

                    contactData.put(
                        'Email',
                        con.Email
                    );

                    contactData.put(
                        'Phone',
                        con.Phone
                    );

                    contactData.put(
                        'Title',
                        con.Title
                    );
                    
                    contactData.put(
                        'Contact Type',
                        con.SW_Contact_Type__c
                    );

                    contacts.add(contactData);
                }

                // --------------------------------
                // Opportunity Data
                // --------------------------------

                List<Map<String, Object>> opportunities =
                    new List<Map<String, Object>>();

                if (
                    accountToOpportunities != null &&
                    accountToOpportunities.containsKey(acc.Id)
                ) {

                    List<Opportunity> relatedOpportunities =
                        accountToOpportunities.get(acc.Id);

                    for (
                        Opportunity opp :
                        relatedOpportunities
                    ) {

                        Map<String, Object> opportunityData =
                            new Map<String, Object>();

                        opportunityData.put(
                            'Id',
                            opp.Id
                        );

                        opportunityData.put(
                            'Status',
                            opp.StageName
                        );

                        opportunities.add(
                            opportunityData
                        );
                    }
                }

                // --------------------------------
                // Final Payload
                // --------------------------------

                Map<String, Object> payload =
                    new Map<String, Object>();

                payload.put(
                    'account',
                    accountData
                );

                payload.put(
                    'contacts',
                    contacts
                );

                payload.put(
                    'opportunities',
                    opportunities
                );

                // --------------------------------
                // Serialize JSON
                // --------------------------------

                String jsonPayload =
                    JSON.serialize(payload);

                System.debug(
                    LoggingLevel.DEBUG,
                    'Create_Account__e Payload: ' +
                    jsonPayload
                );

                // --------------------------------
                // Create Platform Event
                // --------------------------------

                Create_Account__e eventRecord =
                    new Create_Account__e(
                        Payload__c = jsonPayload
                    );

                eventsToPublish.add(
                    eventRecord
                );
            }

            // ------------------------------------
            // Publish All Events in Bulk
            // ------------------------------------

            if (!eventsToPublish.isEmpty()) {

                System.debug(
                    'Event published Test'
                );

                List<Database.SaveResult> results =
                    EventBus.publish(
                        eventsToPublish
                    );

                // --------------------------------
                // Process Results
                // --------------------------------

                for (
                    Integer i = 0;
                    i < results.size();
                    i++
                ) {

                    Database.SaveResult result =
                        results[i];

                    if (result.isSuccess()) {

                        System.debug(
                            LoggingLevel.INFO,
                            'Create_Account__e published successfully.'
                        );

                    } else {

                        for (
                            Database.Error error :
                            result.getErrors()
                        ) {

                            System.debug(
                                LoggingLevel.ERROR,
                                'Create_Account__e publish failed. ' +
                                'Status Code: ' +
                                error.getStatusCode() +
                                ', Message: ' +
                                error.getMessage()
                            );
                        }
                    }
                }
            }

        } catch (QueryException e) {

            System.debug(
                LoggingLevel.ERROR,
                'Account query failed. ' +
                'Account Ids: ' +
                accountIds +
                ', Message: ' +
                e.getMessage() +
                ', Line: ' +
                e.getLineNumber()
            );

        } catch (JSONException e) {

            System.debug(
                LoggingLevel.ERROR,
                'JSON serialization failed. ' +
                'Account Ids: ' +
                accountIds +
                ', Message: ' +
                e.getMessage() +
                ', Line: ' +
                e.getLineNumber()
            );

        } catch (DmlException e) {

            System.debug(
                LoggingLevel.ERROR,
                'Platform Event publishing failed. ' +
                'Account Ids: ' +
                accountIds +
                ', Message: ' +
                e.getMessage() +
                ', Line: ' +
                e.getLineNumber()
            );

        } catch (Exception e) {

            System.debug(
                LoggingLevel.ERROR,
                'Unexpected error in ' +
                'AccountContactEventPublisher. ' +
                'Account Ids: ' +
                accountIds +
                ', Exception: ' +
                e.getTypeName() +
                ', Message: ' +
                e.getMessage() +
                ', Line: ' +
                e.getLineNumber()
            );
        }
    }
}