//
//  LSNetworkManager_Extention.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/22/24.
//

import Foundation
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore

enum LSAWSCognitoAction {
    case changePassword
    case signedIn
    case none
    
}

extension LSNetworkManager {

    func signIn(username: String, password: String) async throws -> LSAWSCognitoAction  {
        let signInResult = try await Amplify.Auth.signIn(
            username: username,
            password: password
        )
        print("Signin Results =", signInResult)
        switch signInResult.nextStep {
        case .confirmSignInWithNewPassword( _):
            return .changePassword
        default:
            print("")
        }
        
        if signInResult.isSignedIn {
            print("Sign in succeeded")
            if let _ = try await fetchAuthSession() {
                return .signedIn
            }
            return .signedIn
        }
        return .none
    }
    
    func currentUser() async throws -> AuthUser {
          let currentUser = try await Amplify.Auth.getCurrentUser()
        print("Current User =", currentUser.userId)
        return currentUser
    }
    
    func signoutUser() async throws {
       let _ = await Amplify.Auth.signOut() as AuthSignOutResult
    }
        
    func confirmSignIn(password: String) async throws -> AuthCognitoTokens? {
            let signInResult = try await Amplify.Auth.confirmSignIn(challengeResponse: password)
        if signInResult.isSignedIn {
            print("Sign in succeeded")
            return try await fetchAuthSession()
        }
        return nil
    }
    
    func changePassword(oldPassword: String, newPassword: String) async throws {
        try await Amplify.Auth.update(oldPassword: oldPassword, to: newPassword)
    }
    
    func forgotPassword(for username: String) async throws -> AuthResetPasswordResult {
        let resetResult = try await Amplify.Auth.resetPassword(for: username)
        
        if resetResult.isPasswordReset {
            print("Password reset completed directly. No confirmation code required.")
            return resetResult
        } else {
            print("Confirmation code sent. Next step: \(resetResult.nextStep)")
            return resetResult
        }
    }
    
    func confirmForgotPassword(username: String, newPassword: String, confirmationCode: String) async throws {
            try await Amplify.Auth.confirmResetPassword(
                for: username,
                with: newPassword,
                confirmationCode: confirmationCode
            )
            print("Password reset confirmed successfully.")
    }


     func fetchAuthSession() async throws -> AuthCognitoTokens? {
            let session = try await Amplify.Auth.fetchAuthSession()
            // Get cognito user pool token
            if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                print("Tokens - \(tokens)")
                print("Access Token =", tokens.accessToken)
                return tokens
            }
        return nil
    }

}

