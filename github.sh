#!/bin/zsh

##Variables
last_week=$(date -u -d '1 week ago' +%Y-%m-%dT00:00:00Z)
EMAIL_FROM="example-email@example-domain.com"
EMAIL_TO="manager@example-domain.com"
SUBJECT="Pull Request Report"

##Ask user for details
#read -p "Enter repository name: " REPO_NAME
#read -p "Enter repository Owner: " OWNER
#read -p "Enter Auth token: " GITHUB_TOKEN

REPO_NAME=UnityProyecto-SeptiembreDiciembre2023
OWNER=reydflores

API="https://api.github.com/repos/$OWNER/$REPO_NAME/pulls"

##GET Pull Requests

search_func() {

        curl -L -H  "Accept: application/vnd.github+json" "$API?state=$1&since=$2&per_page=100"
}

#Fetch PRs
openPR=$(search_func "open" "$last_week")
closedPR=$(search_func "closed" "$last_week")

#search by date
echo $last_week
dateOpenPR=$(echo "$openPR"  | jq -r --arg date "$last_week" '. [] | select(.created_at > $date)' )
dateClosePR=$(echo "$closedPR"  | jq -r --arg date "$last_week" '. [] | select(.closed_at > $date)' )

#Capture formatted output of jq in variables

formattedOpenPRs=$(echo "$dateOpenPR" | jq -r '. | "URL: " + .html_url + "\nState: " + .state + "\nTitle: " + .title + "\nDescription: " + (.body // "No description") + "\nCreated: " + .created_at + "\nUpdated: " + .updated_at + "\nMerged: " + (.merged_at // "N/A") + "\nClosed: " + (.closed_at // "N/A") + "\n\n"')
formattedClosedPRs=$(echo "$dateClosePR" | jq -r '. | "URL: " + .html_url + "\nState: " + .state + "\nTitle: " + .title + "\nDescription: " + (.body // "No description") + "\nCreated: " + .created_at + "\nUpdated: " + .updated_at + "\nMerged: " + (.merged_at // "N/A") + "\nClosed: " + (.closed_at // "N/A") + "\n\n"')

#Construct EMAIL

BODY=$(cat <<EOF
This report summarizes pull request on $REPO_NAME within the last week:

========OPEN PRs========
$formattedOpenPRs
========================


========CLOSED PRs======
$formattedClosedPRs
========================

If you have any question please reach out to the Development team at dev-team@example-domain.com

Kind regards
EOF
)

#PRINT EMAIL

echo "From: $EMAIL_FROM"
echo "To: $EMAIL_TO"
echo "Subject: $SUBJECT"
echo "Body: "
echo "$BODY"
