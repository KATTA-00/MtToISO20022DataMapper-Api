import ballerina/http;
import ballerina/log;
import ballerinax/MTConversion;

// Represents the subtype of http:Ok status code record for successful conversion.
type SwiftToIso20022Response record {|
    *http:Ok;
    string mediaType = "application/xml";
    xml body;
|};

// Represents the subtype of http:BadRequest status code record for invalid input.
type SwiftToIso20022BadRequest record {|
    *http:BadRequest;
    string body;
|};

# This service converts SWIFT messages to ISO 20022 XML.
# The service is exposed at `/transform` and listens to HTTP requests at port `9090`.
service / on new http:Listener(9090) {

    # SWIFT to ISO 20022 transformation service.
    # + return - Transformed ISO 20022 XML or an appropriate error response.
    resource function post transform(@http:Payload string swiftMessage)
        returns SwiftToIso20022Response|SwiftToIso20022BadRequest {
        xml|error iso20022Xml = MTConversion:toISO20022Xml(swiftMessage);
        if iso20022Xml is xml {
            log:printDebug("SWIFT to ISO 20022 conversion successful.");
            return <SwiftToIso20022Response>{body: iso20022Xml};
        } else {
            string diagnosticMsg = iso20022Xml.message();
            log:printError("Error in SWIFT to ISO 20022 conversion.", iso20022Xml);
            return <SwiftToIso20022BadRequest>{body: diagnosticMsg};
        }
    }
}
