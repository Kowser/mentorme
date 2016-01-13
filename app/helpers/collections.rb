module Collections
# --------- PROFILE TEMPLATE FIELDS -----------
  STATE = [
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
    'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
    'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
    'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
    'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
    'DC'
  ]

  GRADES = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th', '11th', '12th']

  ETHNICITY = [
    "African American",
    "American Indian or Alaskan Native",
    "Asian",
    "Caucasian",
    "Hispanic",
    "Native Hawaiian or Other Pacific Islander",
    "Other"
  ]

# --------- STEP COLLECTIONS -----------
  USER_TYPES = {
    'mentor' => 'Mentor Onboarding Process',
    'mentee' => 'Mentee Onboarding Process',
    'all' => 'General Onboarding Process'
  }

  STEP_TYPES = {
    'boolean' => 'Staff Checkbox',
    'custom' => 'Custom Application',
    'template' => 'Template Application'
  }

# --------- TEMPLATE CHECKBOX FIELDS -----------
  TEMPLATES = [
    ['Contact Information', 'profile'],
    ['Employment Information', 'employment'],
    ['Guardian Information', 'guardian'],
    ['Physician Information', 'physician']
  ]

  PROFILE_TEMPLATE_FIELDS = [
    ['Ethnicity', 'ethnicity'],
    ['Birth Date', 'birth_date'],
    ['Address, City, State, Zip', 'address'],
    ['Cell Phone', 'cell_phone'],
    ['Home Phone', 'home_phone'],
    ['Work Phone', 'work_phone'],
    ['Which phone number should we use to call you?', 'phone_preference'],
    ['Mentee - Where do you go to school?', 'school'],
    ['Mentee - What grade are you in?', 'grade']
  ]

  EMPLOYMENT_TEMPLATE_FIELDS = [
    ['Job Title', 'title'],
    ['Years with current employer', 'length'],
    ["Employer Name", 'name'],
    ['Address, City, State, Zip', 'address']
  ]

  GUARDIAN_TEMPLATE_FIELDS = [
    ["Guardian's Name", 'name'],
    ["What is your guardian's relationship to you?", 'relation'],
    ['Address, City, State, Zip', 'address'],
    ['Phone (Will require at least one cell or home)', 'phone'],
    ['Work Phone (Extra phone option: But at least one # total will be required)', 'work_phone'],
    ['Which phone number should we use to call?', 'phone_preference']
  ]

  PHYSICIAN_TEMPLATE_FIELDS = [
    ["Who is your primary care physician?", 'name'],
    ["What is the physician's phone number?", 'phone'],
    ["Who is your medical insurance provider?", 'provider'],
    ["What is the policy number?", 'policy'],
    ["What is the insurance provider's phone number?", 'insurance_phone']
  ]

# --------- CUSTOM FORM COLLECTIONS -----------
  QUESTION_TYPE = [
      ["Text (Written)", "text"],
      ["Select (drop down)", "select"],
      ["Radio (choose one)", "radio"],
      ["Check Boxes (multi-select)", "check_boxes"]
    ]

# --------- OTHER -----------
  CHECK_IN_MEETING_TYPE = ["In Person", "via Phone", "via Videochat"]
  CHECK_IN_LENGTH = (0.5..3).step(0.25)

  BG_STYLES = {
    'Error' => 'danger',
    'Consider' => 'danger',
    'Disputed' => 'danger',
    'Pending' => 'warning',
    'Clear' => 'success'
  }

  BG_AUTHORIZATION = 
    "I acknowledge receipt of the separate document entitled DISCLOSURE REGARDING BACKGROUND INVESTIGATION and 
    A SUMMARY OF YOUR RIGHTS UNDER THE FAIR CREDIT REPORTING ACT and certify that I have read and understand both of those documents. 
    I hereby authorize the obtaining of “consumer reports” and/or “investigative consumer reports” by the Company at any time after receipt 
    of this authorization and throughout my employment, if applicable.  To this end, I hereby authorize, without reservation, any law 
    enforcement agency, administrator, state or federal agency, institution, school or university (public or private), information service 
    bureau, employer, or insurance company to furnish any and all background information requested by 
    Checkr, Inc., 550 15th Street, Suite 27, San Francisco CA 94103 | 844-824-3247 | support@checkr.com. 
    I agree that an electronic copy of this Authorization shall be as valid as the original.
    <table class='table table-bordered'>
      </td></tr>
      <tr><td>
        New York applicants only: Upon request, you will be informed whether or not a consumer report was requested by the Company, and if such
        report was requested, informed of the name and address of the consumer reporting agency that furnished the report.  You have the right to 
        inspect and receive a copy of any investigative consumer report requested by the Company by contacting the consumer reporting agency 
        identified above directly. By signing below, you acknowledge receipt of Article 23-A of the New York Correction Law
      </td></tr>
      <tr><td>
        Washington State applicants only: You also have the right to request from the consumer reporting agency a written summary of your rights and 
        remedies under the Washington Fair Credit Reporting Act.
      </td></tr>
      <tr><td>
        Minnesota and Oklahoma applicants only: Please check the box if you would like to receive a copy of a consumer report if one is obtained by the Company.
      </td></tr>
      <tr><td>
        California applicants only:  Under California Civil Code section 1786.22, you are entitled to find out what is in the CRA’s file on you with proper 
        identification, as follows: <br>
        <ul>
          <li>In person, by visual inspection of your file during normal business hours and on reasonable notice.  You also may request a copy of the information in person. The CRA may not charge you more than the actual copying costs for providing you with a copy of your file.</li>
          <li>A summary of all information contained in the CRA file on you that is required to be provided by the California Civil Code will be provided to you via telephone, if you have made a written request, with proper identification, for telephone disclosure, and the toll charge, if any, for the telephone call is prepaid by or charged directly to you.</li>
          <li>By requesting a copy be sent to a specified addressee by certified mail.  CRAs complying with requests for certified mailings shall not be liable for disclosures to third parties caused by mishandling of mail after such mailings leave the CRAs.</li>
        </ul>
        “Proper Identification” includes documents such as a valid driver’s license, social security account number, military identification card, and credit cards.  Only if you cannot identify yourself with such information may the CRA require additional information concerning your employment and personal or family history in order to verify your identity. The CRA will provide trained personnel to explain any information furnished to you and will provide a written explanation of any coded information contained in files maintained on you.  This written explanation will be provided whenever a file is provided to you for visual inspection.  You may be accompanied by one other person of your choosing, who must furnish reasonable identification.  An CRA may require you to furnish a written statement granting permission to the CRA to discuss your file in such person’s presence.
        <br><br>
        Please check the box if you would like to receive a copy of an investigative consumer report or  consumer credit report at no charge if one is obtained by the Company whenever you have a right to receive such a copy under California law.
      </td></tr>
    </table>"
end
