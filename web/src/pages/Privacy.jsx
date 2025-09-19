import React from 'react'
import Header from '../components/Header'
import Footer from '../components/Footer'

function Privacy() {
  return (
    <>
      <Header showNavigation={false} />

      <main className="max-w-4xl mx-auto px-5 pt-24">
        <div className="bg-cloud-white rounded-3xl shadow-lg p-10 my-10">
          <h1 className="text-4xl font-bold text-night-grey mb-4 text-center">Privacy Policy</h1>
          <p className="text-shadow-grey text-center mb-10">Your privacy and the security of your dreams matter to us</p>

          <div className="bg-fog-grey rounded-xl p-4 text-center text-shadow-grey text-sm mb-8">
            <strong>Last updated:</strong> September 9, 2025
          </div>

          <div className="bg-ultra-light-purple border border-light-purple rounded-2xl p-6 my-6">
            <h3 className="text-primary-purple mb-3 flex items-center gap-2">
              <i className="fas fa-shield-alt"></i> Your Privacy Commitment
            </h3>
            <p className="text-shadow-grey">At Dreamdex, we believe your dreams are deeply personal. We are committed to protecting your privacy and ensuring that your dream journal remains secure and private. This policy explains how we collect, use, and protect your information.</p>
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-semibold text-primary-purple mb-4 flex items-center gap-2">
              <i className="fas fa-info-circle"></i> Information We Collect
            </h2>

            <h3 className="text-lg font-semibold text-night-grey mb-3 mt-5">Personal Information</h3>
            <p className="text-shadow-grey mb-4 text-justify">When you create an account with Dreamdex, we collect:</p>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2">Name and email address</li>
              <li className="mb-2">Profile information you choose to provide</li>
              <li className="mb-2">Account preferences and settings</li>
            </ul>

            <h3 className="text-lg font-semibold text-night-grey mb-3 mt-5">Dream Content</h3>
            <p className="text-shadow-grey mb-4 text-justify">The core of our service involves collecting your dream-related information:</p>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2">Dream descriptions and journal entries</li>
              <li className="mb-2">Voice recordings (converted to text, audio not stored)</li>
              <li className="mb-2">Dream tags, categories, and metadata</li>
              <li className="mb-2">AI-generated analysis and insights</li>
            </ul>

            <h3 className="text-lg font-semibold text-night-grey mb-3 mt-5">Usage Information</h3>
            <p className="text-shadow-grey mb-4 text-justify">To improve our service, we collect:</p>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2">App usage patterns and feature interactions</li>
              <li className="mb-2">Device information and technical data</li>
              <li className="mb-2">Error logs and performance metrics</li>
            </ul>
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-semibold text-primary-purple mb-4 flex items-center gap-2">
              <i className="fas fa-cogs"></i> How We Use Your Information
            </h2>

            <p className="text-shadow-grey mb-4 text-justify">Your information is used exclusively to provide and improve the Dreamdex service:</p>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2"><strong>Dream Analysis:</strong> AI processing of your dreams to provide insights and patterns</li>
              <li className="mb-2"><strong>Service Delivery:</strong> Storing, syncing, and retrieving your dream journal across devices</li>
              <li className="mb-2"><strong>Support:</strong> Providing customer support and troubleshooting</li>
            </ul>
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-semibold text-primary-purple mb-4 flex items-center gap-2">
              <i className="fas fa-share-alt"></i> Information Sharing
            </h2>

            <p className="text-shadow-grey mb-4 text-justify"><strong>We do not sell, rent, or share your personal information or dream content with third parties</strong>, except in the following limited circumstances:</p>

            <h3 className="text-lg font-semibold text-night-grey mb-3 mt-5">Service Providers</h3>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2"><strong>Convex:</strong> Database hosting and real-time sync</li>
              <li className="mb-2"><strong>Firebase:</strong> Authentication and user management</li>
              <li className="mb-2"><strong>Google AI:</strong> Dream analysis processing (content is processed but not stored by Google)</li>
              <li className="mb-2"><strong>RevenueCat:</strong> Subscription and payment processing</li>
            </ul>

            <h3 className="text-lg font-semibold text-night-grey mb-3 mt-5">Legal Requirements</h3>
            <p className="text-shadow-grey mb-4 text-justify">We may disclose information if required by law, court order, or to protect our rights and the safety of our users.</p>
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-semibold text-primary-purple mb-4 flex items-center gap-2">
              <i className="fas fa-lock"></i> Data Security
            </h2>

            <p className="text-shadow-grey mb-4 text-justify">We implement industry-standard security measures to protect your information:</p>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2">End-to-end encryption for data transmission</li>
              <li className="mb-2">Secure database storage with access controls</li>
              <li className="mb-2">Regular security audits and updates</li>
              <li className="mb-2">Limited employee access on a need-to-know basis</li>
            </ul>
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-semibold text-primary-purple mb-4 flex items-center gap-2">
              <i className="fas fa-user-check"></i> Your Rights and Choices
            </h2>

            <p className="text-shadow-grey mb-4 text-justify">You have complete control over your data:</p>

            <h3 className="text-lg font-semibold text-night-grey mb-3 mt-5">Access and Control</h3>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2">View, edit, or delete any dream entry</li>
              <li className="mb-2">Modify account settings and preferences</li>
              <li className="mb-2">Request a copy of all your stored data</li>
            </ul>

            <h3 className="text-lg font-semibold text-night-grey mb-3 mt-5">Account Deletion</h3>
            <p className="text-shadow-grey mb-4 text-justify">You can permanently delete your account and all associated data through the app settings. This action:</p>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2">Removes all dream entries and personal information</li>
              <li className="mb-2">Cancels any active subscriptions</li>
              <li className="mb-2">Cannot be reversed once completed</li>
            </ul>
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-semibold text-primary-purple mb-4 flex items-center gap-2">
              <i className="fas fa-clock"></i> Data Retention
            </h2>

            <p className="text-shadow-grey mb-4 text-justify">We retain your information as follows:</p>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2"><strong>Active Accounts:</strong> Data is retained while your account is active</li>
              <li className="mb-2"><strong>Inactive Accounts:</strong> Data may be deleted after 2 years of inactivity (with prior notice)</li>
              <li className="mb-2"><strong>Deleted Accounts:</strong> All data is permanently removed immediately</li>
            </ul>
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-semibold text-primary-purple mb-4 flex items-center gap-2">
              <i className="fas fa-child"></i> Children's Privacy
            </h2>

            <p className="text-shadow-grey mb-4 text-justify">Dreamdex is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If we discover we have collected such information, we will delete it immediately.</p>
          </div>

          <div className="mb-8">
            <h2 className="text-2xl font-semibold text-primary-purple mb-4 flex items-center gap-2">
              <i className="fas fa-edit"></i> Changes to This Policy
            </h2>

            <p className="text-shadow-grey mb-4 text-justify">We may update this privacy policy from time to time. When we do:</p>
            <ul className="text-shadow-grey pl-6 mb-4 list-disc">
              <li className="mb-2">We will notify you through the app and by email</li>
              <li className="mb-2">The "Last updated" date will be revised</li>
              <li className="mb-2">Continued use of the app constitutes acceptance of changes</li>
              <li className="mb-2">Significant changes will require explicit consent</li>
            </ul>
          </div>

          <div className="bg-gradient-to-br from-ultra-light-purple to-light-blue rounded-3xl p-8 text-center mt-10">
            <h3 className="text-primary-purple mb-4 flex items-center justify-center gap-2">
              <i className="fas fa-envelope"></i> Contact Us
            </h3>
            <p className="text-shadow-grey mb-4">If you have questions about this privacy policy or your data, please contact us:</p>
            <p className="mb-4">
              <strong>Email:</strong> <a href="mailto:contact@dreamdexapp.com" className="text-dream-blue no-underline font-medium hover:text-primary-purple">contact@dreamdexapp.com</a>
            </p>
            <p className="text-sm text-shadow-grey">
              We aim to respond to all privacy inquiries within 48 hours.
            </p>
          </div>
        </div>
      </main>

      <Footer />
    </>
  )
}

export default Privacy