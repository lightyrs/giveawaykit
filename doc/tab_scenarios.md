# Tab Scenarios

## Types of Visitors

1. Fan or Non-Fan
2. New Visit or Return Visit
3. Authenticated or Non-Authenticated
4. Entrant or Non-Entrant
5. Referred or Direct

## Types of Giveaways

1. Authentication or Email
2. Single-Entry or Multi-Entry
3. Scheduled End-Date or No End-Date

## Statistics

1. Total Points
  - Entry Count
  - Bonus Entries for Converted Referrals

2. Points Rank
  - Entrant points compared to other entrant points

3. Giveaway Days Remaining
  - If scheduled end-date

### Checks

1. Entry submission
  - For fan
    - For authenticated
      - For giveaway that requires authentication
      - For giveaway that doesn't require authentication
    - For non-authenticated
      - For giveaway that requires authentication
      - For giveaway that doesn't require authentication
  - For non-fan
    - For authenticated
      - For giveaway that requires authentication
      - For giveaway that doesn't require authentication
    - For non-authenticated
      - For giveaway that requires authentication
      - For giveaway that doesn't require authentication

2. Entry resubmission
  - For giveaway that allows multiple entries
    - Entry count is updated
    - Entrant points are updated
  - For giveaway that does not allow multiple entries ✔
    - Entry count is not updated ✔
    - Entrant points are not updated ✔
    - Entrant is given 'already entered' message ✔

3. Entry sharing ✔
  - Wall Post
    - Count is updated ✔
  - App Request
    - Count is updated ✔
  - Shortlink
    - Exists and remains static for each entrant ✔

4. Entry referral
  - Single Referrer
    - Conversion is counted for referrer
  - Multiple Referrers
    - Conversions are counted for all referrers

5. Canvas
  - Wall Post
    - Routes to giveaway with referrer_id
  - App Request
    - When there are multiple
      - Routes to most recent giveaway with referrer_id
      - Requests get deleted after use
    - When there is one
      - Routes to giveaway with referrer_id
      - Request is deleted after use

6. Liking
  - Direct Visit
    - Like is counted
  - Viral Visit
    - Like is counted and marked as viral
    - Referrer/s are credited (future)
  - From Entry
    - Like is counted and marked as from entry

### Strategies

1. Facebook Share
  - Redirect the enter page to the tab page only if the request is coming from facebook
  - Otherwise, show the enter form on giveawaykit (or wherever embedded)