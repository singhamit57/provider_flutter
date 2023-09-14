import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

const APP_NAME = 'KB Provider';
const DEFAULT_LANGUAGE = 'en';

const primaryColor = Color(0xFFF86035);

const DOMAIN_URL = 'http://bricksmart.in/handyman'; // Don't add slash at the end of the url
const BASE_URL = "$DOMAIN_URL/api/";

/// You can specify in Admin Panel, These will be used if you don't specify in Admin Panel
const IOS_LINK_FOR_PARTNER = " ";

const TERMS_CONDITION_URL = 'http://koibanda.com/terms-and-conditions';
const PRIVACY_POLICY_URL = 'http://www.koibanda.com/privacy-policy';
const INQUIRY_SUPPORT_EMAIL = 'info@koibanda.com';

const GOOGLE_MAPS_API_KEY = 'WeraWetHJwjZjGSOBc18-3mJM9uIqDYoV6Lo9tQ';

const STRIPE_MERCHANT_COUNTRY_CODE = 'IN';

DateTime todayDate = DateTime(2023, 9, 11);

/// SADAD PAYMENT DETAIL
const SADAD_API_URL = 'https://api-s.sadad.qa';
const SADAD_PAY_URL = "https://d.sadad.qa";

/// You can update OneSignal Keys from Admin Panel in Setting.
/// These keys will be used if you haven't added in Admin Panel.

const ONESIGNAL_APP_ID = '7b57eb68-ab6f-43dc-8eed-86ede31399da';
const ONESIGNAL_REST_KEY = "ODdmOTBmOTgtMWVmZi00NzFjLWFmNGQtZjAxZjdlYzg3ZTUy";
const ONESIGNAL_CHANNEL_ID = "3a710d48-51fd-4e64-b27f-3b61c863b215";

Country defaultCountry() {
  return Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 91,
    geographic: true,
    level: 1,
    name: 'India',
    example: '6392363869',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '91-IN-0',
    fullExampleWithPlusSign: '6392363869',
  );
}
