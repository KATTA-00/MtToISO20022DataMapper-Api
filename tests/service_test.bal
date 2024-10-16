import ballerina/http;
import ballerina/io;
import ballerina/test;

http:Client testClient = check new ("http://localhost:9090");

map<string> swiftMessages = {};
xml expectedIso20022Xml = xml `<iso20022></iso20022>`;

@test:BeforeSuite
function beforeSuiteFunc() returns error? {
    swiftMessages["valid"] = check io:fileReadString("tests/test_valid_swift_message.txt");
    swiftMessages["invalid"] = check io:fileReadString("tests/test_invalid_swift_message.txt");
}

@test:Config {}
function testValidSwiftToIso20022() returns error? {
    http:Response|error response = testClient->/transform.post(swiftMessages["valid"]);
    test:assertTrue(response is http:Response, "Error occurred while transforming SWIFT message to ISO 20022!");

    if (response is http:Response) {
        test:assertEquals(response.statusCode, 200, "Response status code mismatched!");
    }
}

@test:Config {}
function testInvalidSwiftMessage() returns error? {
    http:Response|error response = testClient->/transform.post(swiftMessages["invalid"]);

    if (response is http:Response) {
        test:assertEquals(response.statusCode, 400, "Response status code mismatched!");
        string errorMsg = check response.getTextPayload();
        test:assertTrue(errorMsg.startsWith("required field"),
                "Expected error message for invalid SWIFT message is incorrect.");
    }
}
