import React from 'react'
import Header from '../components/Header'
import Footer from '../components/Footer'

function Terms() {
  return (
    <>
      <Header showNavigation={false} />

      <main className="max-w-4xl mx-auto px-5 pt-24">
        <div className="bg-cloud-white rounded-3xl shadow-lg p-10 my-10">
          <h1 className="text-4xl font-bold text-night-grey mb-4 text-center">Terms of Service</h1>
          <p className="text-shadow-grey text-center mb-10">Please read these terms carefully before using Dreamdex</p>

          <div className="bg-fog-grey rounded-xl p-4 text-center text-shadow-grey text-sm mb-8">
            <strong>Last updated:</strong> September 9, 2025
          </div>

          <div className="bg-ultra-light-purple border border-light-purple rounded-2xl p-6 my-6">
            <h3 className="text-primary-purple mb-3 flex items-center gap-2">
              <i className="fas fa-handshake"></i> Agreement to Terms
            </h3>
            <p className="text-shadow-grey">By downloading, installing, or using the Dreamdex application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our service.</p>
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-semibold text-primary-purple mb-4 flex items-center gap-2">
              <i className="fas fa-info-circle"></i> About Dreamdex
            </h2>
            <p className="text-shadow-grey mb-4 text-justify">Dreamdex is an AI-powered dream journal application that helps users record, analyze, and understand their dreams. Our service includes:</p>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2">Digital dream journaling with voice-to-text recording</li>
              <li className="mb-2">AI-powered dream analysis and pattern recognition</li>
              <li className="mb-2">Secure cloud storage and cross-device synchronization</li>
              <li className="mb-2">Premium features through optional subscriptions</li>
            </ul>
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-semibold text-primary-purple mb-4 flex items-center gap-2">
              <i className="fas fa-user"></i> User Accounts and Responsibilities
            </h2>
            <h3 className="text-lg font-semibold text-night-grey mb-3 mt-5">Account Creation</h3>
            <p className="text-shadow-grey mb-4 text-justify">To use Dreamdex, you must:</p>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2">Be at least 13 years old (or legal age in your jurisdiction)</li>
              <li className="mb-2">Provide accurate and truthful information</li>
              <li className="mb-2">Maintain the security of your account credentials</li>
              <li className="mb-2">Use the service in compliance with applicable laws</li>
            </ul>

            <h3 className="text-lg font-semibold text-night-grey mb-3 mt-5">Account Security</h3>
            <p className="text-shadow-grey mb-4 text-justify">You are responsible for:</p>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2">Keeping your login credentials confidential</li>
              <li className="mb-2">All activities that occur under your account</li>
              <li className="mb-2">Immediately notifying us of any unauthorized access</li>
              <li className="mb-2">Using strong passwords</li>
            </ul>
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-semibold text-primary-purple mb-4 flex items-center gap-2">
              <i className="fas fa-gavel"></i> Acceptable Use
            </h2>
            <p className="text-shadow-grey mb-4 text-justify">When using Dreamdex, you agree to:</p>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2">Use the service only for personal, non-commercial purposes</li>
              <li className="mb-2">Respect the intellectual property rights of others</li>
              <li className="mb-2">Not attempt to reverse engineer or hack the application</li>
              <li className="mb-2">Not share inappropriate, illegal, or harmful content</li>
              <li className="mb-2">Not use the service to spam or harass others</li>
              <li className="mb-2">Not create multiple accounts to circumvent limitations</li>
            </ul>

            <div className="bg-red-50 border border-red-200 rounded-2xl p-6 my-6">
              <h3 className="text-error-red mb-3 flex items-center gap-2">
                <i className="fas fa-exclamation-triangle"></i> Prohibited Activities
              </h3>
              <p className="text-red-800">Violation of these terms may result in immediate account suspension or termination without refund.</p>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-semibold text-primary-purple mb-4 flex items-center gap-2">
              <i className="fas fa-file-alt"></i> Your Content and Data
            </h2>
            <h3 className="text-lg font-semibold text-night-grey mb-3 mt-5">Ownership</h3>
            <p className="text-shadow-grey mb-4 text-justify">You retain full ownership of all dreams, journal entries, and personal content you create in Dreamdex. We do not claim ownership of your dreams or personal data.</p>

            <h3 className="text-lg font-semibold text-night-grey mb-3 mt-5">License to Use</h3>
            <p className="text-shadow-grey mb-4 text-justify">By using our service, you grant us a limited, non-exclusive license to:</p>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2">Store and process your content to provide the service</li>
              <li className="mb-2">Use AI models to analyze your dreams (data is not stored by AI providers)</li>
              <li className="mb-2">Backup and synchronize your data across your devices</li>
              <li className="mb-2">Provide customer support when requested</li>
            </ul>

            <h3 className="text-lg font-semibold text-night-grey mb-3 mt-5">Data Deletion</h3>
            <p className="text-shadow-grey mb-4 text-justify">You can delete your data at any time through the app settings. Upon account deletion, all your data will be permanently removed.</p>
          </div>

          <div className="bg-gradient-to-br from-ultra-light-purple to-light-blue rounded-3xl p-8 text-center mt-10">
            <h3 className="text-primary-purple mb-4 flex items-center justify-center gap-2">
              <i className="fas fa-envelope"></i> Contact Information
            </h3>
            <p className="text-shadow-grey mb-4">If you have questions about these terms or need support, please contact us:</p>
            <p className="mb-4">
              <strong>Email:</strong> <a href="mailto:contact@dreamdexapp.com" className="text-dream-blue no-underline font-medium hover:text-primary-purple">contact@dreamdexapp.com</a>
            </p>
            <p className="text-sm text-shadow-grey">
              We aim to respond to all inquiries within 48 hours.
            </p>
          </div>
        </div>
      </main>

      <Footer />
    </>
  )
}

export default Terms