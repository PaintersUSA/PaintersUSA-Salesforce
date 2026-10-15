/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : AddBusinessDays
 * Author          : Varun Rawal
 * Created Date    : Aug 29, 2026
 * Last Modified By: Varun Rawal
 * Last Modified On: Aug 29, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Aug 29, 2026  │ Varun Rawal   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public with sharing class AddBusinessDays {

    public class Request {
        @InvocableVariable(required=true)
        public Integer businessDays;

        @InvocableVariable(required=true)
        public Id businessHoursId;

        @InvocableVariable
        public Date startDate;
    }

    public class Response {
        @InvocableVariable
        public Date resultDate;
    }

    @InvocableMethod(label='Calculate Business Days')
    public static List<Response> calculateBusinessDays(
        List<Request> requests
    ) {
        List<Response> results = new List<Response>();

        for (Request req : requests) {

            Date startDate = req.startDate != null
                ? req.startDate
                : Date.today();

            Integer daysRequired = req.businessDays;

            Date currentDate = startDate;
            Integer businessDaysCount = 0;

            while (businessDaysCount < daysRequired) {

                // Move to the next calendar day
                currentDate = currentDate.addDays(1);

                Datetime dayStart = Datetime.newInstance(
                    currentDate,
                    Time.newInstance(0, 0, 0, 0)
                );

                Datetime dayEnd = dayStart.addDays(1);

                // Check whether this date has Business Hours
                Long businessTime = BusinessHours.diff(
                    req.businessHoursId,
                    dayStart,
                    dayEnd
                );

                if (businessTime > 0) {
                    businessDaysCount++;
                }
            }

            Response response = new Response();
            response.resultDate = currentDate;

            results.add(response);
        }

        return results;
    }
}