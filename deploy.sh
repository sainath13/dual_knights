#!/bin/bash

# Set your Amplify app ID and branch name
AWS_APP_ID="your-app-id"    # Replace with your actual app ID
BRANCH_NAME="main"          # Replace with your actual branch name

# Build the Flutter web app
flutter clean
flutter pub get
flutter build web

# Create deployment zip
cd build/web
zip -r ../../build.zip *
cd ../..

# Deploy to Amplify
aws amplify start-deployment \
  --app-id $AWS_APP_ID \
  --branch-name $BRANCH_NAME \
  --zip-file fileb://build.zip

# Clean up
rm build.zip
