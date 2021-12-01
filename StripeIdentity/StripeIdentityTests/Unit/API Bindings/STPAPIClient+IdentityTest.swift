//
//  STPAPIClient+IdentityTest.swift
//  StripeIdentityTests
//
//  Created by Mel Ludowise on 10/27/21.
//

import XCTest
import OHHTTPStubs
@testable @_spi(STP) import StripeCore
import StripeCoreTestUtils
@testable import StripeIdentity

final class STPAPIClient_IdentityTest: APIStubbedTestCase {

    func testCreateVerificationPage() throws {
        let mockId = "VS_123"
        let mockEAK = "ephemeral_key_secret"

        let mockVerificationPage = VerificationPageMock.response200
        let mockResponseData = try mockVerificationPage.data()
        let mockResponse = try mockVerificationPage.make()

        let exp = expectation(description: "Request completed")

        stub { urlRequest in
            XCTAssertEqual(urlRequest.url?.absoluteString.hasSuffix("v1/identity/verification_pages/\(mockId)?"), true)
            XCTAssertEqual(urlRequest.httpMethod, "GET")
            XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Authorization"], "Bearer \(mockEAK)")

            return true
        } response: { urlRequest in
            return HTTPStubsResponse(data: mockResponseData, statusCode: 200, headers: nil)
        }

        let apiClient = stubbedAPIClient()
        let promise = apiClient.getIdentityVerificationPage(
            id: mockId,
            ephemeralKeySecret: mockEAK
        )
        promise.observe { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response, mockResponse)
            case .failure(let error):
                XCTFail("Request returned error \(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func testUpdateVerificationPageData() throws {
        let mockId = "VS_123"
        let mockEAK = "ephemeral_key_secret"
        let mockVerificationData = makeMockVerificationPageDataUpdate()
        let encodedMockVerificationData = URLEncoder.queryString(from: try mockVerificationData.encodeJSONDictionary())

        let mockVerificationPageData = VerificationPageDataMock.response200
        let mockResponseData = try mockVerificationPageData.data()
        let mockResponse = try mockVerificationPageData.make()

        let exp = expectation(description: "Request completed")

        stub { urlRequest in
            XCTAssertEqual(urlRequest.url?.absoluteString.hasSuffix("v1/identity/verification_pages/\(mockId)/data"), true)
            XCTAssertEqual(urlRequest.httpMethod, "POST")

            XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Authorization"], "Bearer \(mockEAK)")

            guard let httpBody = urlRequest.ohhttpStubs_httpBody else {
                XCTFail("Expected an httpBody but found none")
                return false
            }
            XCTAssertEqual(String(data: httpBody, encoding: .utf8), encodedMockVerificationData)
            return true
        } response: { urlRequest in
            return HTTPStubsResponse(data: mockResponseData, statusCode: 200, headers: nil)
        }

        let apiClient = stubbedAPIClient()
        let promise = apiClient.updateIdentityVerificationPageData(
            id: mockId,
            updating: mockVerificationData,
            ephemeralKeySecret: mockEAK
        )
        promise.observe { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response, mockResponse)
            case .failure(let error):
                XCTFail("Request returned error \(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func testSubmitIdentityVerificationSession() throws {
        let mockId = "VS_123"
        let mockEAK = "ephemeral_key_secret"
        let mockVerificationPageData = VerificationPageDataMock.response200
        let mockResponseData = try mockVerificationPageData.data()
        let mockResponse = try mockVerificationPageData.make()

        let exp = expectation(description: "Request completed")

        stub { urlRequest in
            XCTAssertEqual(urlRequest.url?.absoluteString.hasSuffix("v1/identity/verification_pages/\(mockId)/submit"), true)
            XCTAssertEqual(urlRequest.httpMethod, "POST")

            XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Authorization"], "Bearer \(mockEAK)")

            XCTAssertEqual(urlRequest.ohhttpStubs_httpBody?.isEmpty, true)
            return true
        } response: { urlRequest in
            return HTTPStubsResponse(data: mockResponseData, statusCode: 200, headers: nil)
        }

        let apiClient = stubbedAPIClient()
        let promise = apiClient.submitIdentityVerificationPage(
            id: mockId,
            ephemeralKeySecret: mockEAK
        )
        promise.observe { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response, mockResponse)
            case .failure(let error):
                XCTFail("Request returned error \(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }
}

private extension STPAPIClient_IdentityTest {
    func makeMockVerificationPageDataUpdate() -> VerificationPageDataUpdate {
        return VerificationPageDataUpdate(
            collectedData: .init(
                address: .init(
                    city: "city",
                    country: "country",
                    line1: "line1",
                    line2: "line2",
                    state: "state",
                    postalCode: "postalCode",
                    _additionalParametersStorage: nil
                ),
                consent: .init(
                    train: true,
                    biometric: false,
                    _additionalParametersStorage: nil
                ),
                dob: .init(
                    day: "day",
                    month: "month",
                    year: "year",
                    _additionalParametersStorage: nil
                ),
                email: "email@address.com",
                face: .init(
                    image: "some_image_id",
                    _additionalParametersStorage: nil
                ),
                idDocument: .init(
                    type: .drivingLicense,
                    front: "some_image_id",
                    back: "some_image_id",
                    _additionalParametersStorage: nil
                ),
                idNumber: .init(
                    country: "country",
                    partialValue: "1234",
                    value: nil,
                    _additionalParametersStorage: nil
                ),
                name: .init(
                    firstName: "first",
                    lastName: "last",
                    _additionalParametersStorage: nil
                ),
                phoneNumber: "1234567890",
                _additionalParametersStorage: nil
            ),
            _additionalParametersStorage: nil
        )
    }
}
