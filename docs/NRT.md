# Non-regression tests (NRT)

Manual non-regression pass run on the **release candidate's own APK**, the staging build from the `vX.Y.Z-rc.N` pre-release, before it goes to testers or to the stores. The unit and widget tests (`flutter test`, CI) catch logic regressions. This pass catches what they can't: the real build, real navigation, the system's dialogs, the keyboard, TalkBack and large text.

Run it on an emulator, or on a phone that is not a personal one, since it clears the app's data. One pass takes about an hour and a half. Record each step as **OK** or **KO** in the [report](#report) and attach a screenshot of every KO.

## Setup

```bash
DEV=emulator-5560                      # adb device to use
RC=v2.5.0-rc.13
APK=io_caravella_egm-staging-2.5.0-rc.13.apk   # from the pre-release's assets
PKG=io.caravella.egm.staging

gh release download $RC -R calca/caravella -p '*.apk' -D /tmp/rc
adb -s $DEV install -r /tmp/rc/$APK
adb -s $DEV shell pm clear $PKG        # fresh start: no groups, no settings
adb -s $DEV shell settings put system font_scale 1.0
adb -s $DEV shell cmd uimode night no
```

Screenshots: `adb -s $DEV exec-out screencap -p > shot.png`. They come out **black** until Settings › Privacy › **Secure screen** is turned off: it is on by default and blocks screenshots and screen recording (the window has `FLAG_SECURE`). Turn it off first, which also tests that switch.

Without screenshots you can still read the screen: `adb -s $DEV shell uiautomator dump` lists every element with its label and bounds, which is how `nrt_a11y_check.sh` works.

## 0. Upgrade from the last release

Run this first, before the fresh install of the setup: it is the only step that tests the database upgrade on real data. The last release's APK on GitHub is the prod build, signed with the release key, and the rc is a staging build, so one can't be installed over the other. Build both from their tags with the same local (debug) key instead, each with the Flutter version its CI pinned:

```bash
git worktree add /tmp/old v2.4.4 && git worktree add /tmp/new $RC
(cd /tmp/old && flutter pub get && flutter build apk --flavor staging --debug --dart-define=FLAVOR=staging)  # Flutter 3.47.6
(cd /tmp/new && flutter pub get && flutter build apk --flavor staging --debug --dart-define=FLAVOR=staging)  # Flutter 3.50.0
adb -s $DEV uninstall $PKG
adb -s $DEV install /tmp/old/build/app/outputs/flutter-apk/app-staging-debug.apk
```

| # | Step | Expected |
|---|---|---|
| 0.1 | On the old version: two groups (one with a photo, one with a colour), four people, ten expenses with a place, a note and attachments; delete a third group; archive one; make a backup (2.4 has no payments to tick yet). To fill it quickly, restore a 2.4-format backup (a JSON list of groups) and copy the photos into the app's files with `run-as` (the debug build allows it) | All saved |
| 0.2 | `adb -s $DEV install -r /tmp/new/build/app/outputs/flutter-apk/app-staging-debug.apk`, then open the app | No crash, no empty Home. Every group, expense, attachment (each once, not repeated) and payment is there, the archived group is still archived, the deleted one doesn't come back. The totals and balances are the same as before the upgrade |
| 0.3 | Edit an expense and a group, then force-stop and reopen | The changes are kept |
| 0.4 | Restore the 2.4 backup made in 0.1 | It is restored |

Then uninstall and go on with the rc's own APK, as in the setup.

## 1. First start and Home

| # | Step | Expected |
|---|---|---|
| 1.1 | Open the app on a fresh install | Onboarding, then the empty Home with "create a group". No crash, no permission prompt at start |
| 1.2 | Create a first group from Home | The wizard opens (see 2.1). Back on Home, the group's card shows its type, title and dates, then Total \| Today, and the recent expenses below. No wave chart |
| 1.3 | Home shortcuts: Scan (Play) or Photo (F-Droid), Voice, Map, Search | Each one opens. Deny the camera or microphone once: a dialog with **Open settings**, not a toast |
| 1.4 | Force-stop and open the app again (cold start), in light and in dark | The launch screen has Home's background and the icon, not the teal one; the icon shrinks into Home and its greeting, card and shortcuts rise in one after the other. Home never shows empty first |
| 1.5 | Phone in dark mode, Caravella in light (Settings › Theme), open Home, go to the launcher, come back. Then the opposite | No dark (or light) frame before Home. Android 12+ only: below it the system's theme may show for a moment |
| 1.6 | Developer options › animations off, cold start | Home just appears, with no animation |
| 1.7 | Tap a recent expense on Home | The group page opens with that expense open; back lands on the group |

## 2. Groups

| # | Step | Expected |
|---|---|---|
| 2.1 | Wizard: type Travel, a name, dates, currency (with a second one and its rate), background (photo, colour, none), participants, categories | The preview card updates as you type. Currency opens the same sheet as General › Currency; the pill reads "Euro · kr". Continue stays off without a name. The new group opens, and a new expense offers "in kr" |
| 2.2 | Settings › General: rename, change the dates, change the type and background, then back | The changes are saved on back, and the header shows them |
| 2.3 | General with an empty name, then back | Back is blocked, the field is focused and a toast explains why |
| 2.4 | Archive the group, find it in Groups › Archived, unarchive it | It moves between the tabs. Home no longer shows it while archived |
| 2.5 | Delete a group | Confirmation, then it is gone from Groups and Home |
| 2.6 | Cards: a group with a colour, one with none, one with a light photo and one with a dark photo, in both themes | Each card is in a tint of its colour (grey without one) with readable text and the type's icon faint in the corner; under a photo the card takes the photo's tone and the photo fades in over it, never popping in |
| 2.7 | Groups tab with five or more groups, one of them the favorite | A grid of same-size tiles, most recent activity first; the favorite has a heart on its chip and no wide card on top |
| 2.8 | Open a group | No spinner or dot in the middle of the screen before the page |

## 3. Expenses

| # | Step | Expected |
|---|---|---|
| 3.1 | Quick sheet: amount, description, paid by, category, Add | Saved. Totals, Today and the list update |
| 3.2 | Quick sheet, then **More details** | The full page opens with what was typed, and the keyboard stays down |
| 3.3 | Full form: date, place, note, two attachments (photo and file) | All saved and shown, each attachment once, when the expense is reopened |
| 3.4 | Open an expense | The top reads like the expense: group · date on a small line, the description as the title, the amount large with its currency after ("42 €"), then "Paid by … · … per person". No "Edit expense" title. Save is grey |
| 3.5 | Change the amount and payer, Save | Save turns on at the first change. The list and balances update |
| 3.6 | ⋯ menu: Share, then Delete expense | Share opens the system sheet. Delete asks for confirmation, then the expense is gone and the totals drop |
| 3.7 | Search from the group and from Home | Matches are highlighted and tapping one opens the expense |
| 3.8 | Voice: "20 euro coffee", then "20 euro" alone | The first is saved. The second opens the form to add the name, and nothing is lost |
| 3.9 | Place, with the location allowed (first time: allow it at the prompt) | The map opens on your position with a blue dot and that spot already picked ("You are here" and the address): one tap on Confirm saves it |
| 3.10 | Place, with the location denied or off | The map opens and says the position couldn't be found; tapping the map or searching still works |
| 3.11 | Search a place that doesn't exist ("zzqx") | A card "No places found for …" with a hint, not an empty map |
| 3.12 | Airplane mode, search a place | After about 10 seconds a calm card with Try again, no red text on the map. Back online, Try again finds it |

## 4. Second currency (2.5)

| # | Step | Expected |
|---|---|---|
| 4.1 | General › Currency: "Add a currency", Norwegian Krone, rate 11.63, Done | Done stays off until there is a rate. The row reads "Expenses also in kr · 1 € = 11.63 kr" |
| 4.2 | New expense: tap **in kr**, type 450 | The amount reads "kr 450". Below it, "= 38.69 € · in €" in grey, and nothing moves |
| 4.3 | Save it | The total and Today grow by 38.69 €. The list shows 38.69 € and 450.00 kr under it |
| 4.4 | Open a new expense | It starts in kr (the last expense was in kr). "in €" goes back to euros |
| 4.5 | Change the rate to 11.20, reopen the 450 kr expense | It still shows = 38.69 €, because each expense keeps the rate it was entered with |
| 4.6 | General › Currency: change the group currency to NOK | The second currency is dropped. Changing to USD instead asks for the rate again |
| 4.7 | Export CSV | "Original amount" and "Original currency" columns appear only when some expense uses them |

## 5. Budget (2.5)

| # | Step | Expected |
|---|---|---|
| 5.1 | Settings › Budget: try each period (in total, monthly, weekly, daily), set 150 a day | The row shows the budget. A trip starts on "In total" |
| 5.2 | Group page header; Statistics | The header shows Total \| Today only, no ring. In Statistics, under the pace card, a Budget card like the map one: "150.00 € a day · on track" |
| 5.3 | Tap the Budget card | The budget sheet: "Budget", the budget and its period ("600.00 € a month · November") and a pencil; what's left, its bar with today marked, "… spent" and the days left; a card "To stay within budget": a day from now to the end beside a day so far, and "At this pace the budget runs out around …" (or "lasts to the end"). Over the budget: amber figure, "… spent of … planned" and a card with the day it starts again, no 0.00 € lines. A daily budget has no pace card (its period is today). Monthly, weekly and daily budgets also show the three periods before, once there are some: rows of the same height, "+42" in amber beside a period that went over |
| 5.4 | Spend faster than the budget allows | The card says "a bit above plan", no colors; the sheet's pace card gives the day it would run out, in words, no amber |
| 5.5 | Remove the budget | The card says "Not set"; tapping it sets a budget again |

## 6. Balances and settle up

| # | Step | Expected |
|---|---|---|
| 6.1 | Balances with four people and uneven expenses | Each person's balance and "paid in all". The figures match Settle up to the cent |
| 6.2 | Tick a suggested payment as paid | It is struck through with "Paid · date". The balances move and the reminder button is gone |
| 6.3 | Untick it | It is back as it was |

## 7. Statistics

| # | Step | Expected |
|---|---|---|
| 7.1 | Statistics tab | Spending pace, the charts, categories and the top 4 payers in one row. No overflow stripes |

## 8. Settings

| # | Step | Expected |
|---|---|---|
| 8.1 | Language: Italiano, then English | All of the app switches, including the dates and currency formats |
| 8.2 | Theme: dark, then light | Every screen above stays readable. Do a quick tour in dark mode |
| 8.3 | What's new | The current version's notes, in the app's language |
| 8.4 | Backup, then delete a group, then restore the backup | The group is back with its expenses, payments, budget and second currency |
| 8.5 | Check for updates (Play build) | No crash. An available update shows no version line |
| 8.6 | Predictive back: drag slowly from the left edge on the group page, the expense form and Settings, then let go or drag back | The page underneath shows as the current one shrinks; letting go goes back, dragging back stays. A group without a name and an expense with unsaved changes still hold you back |
| 8.7 | Sheets: General › Currency › the list, Background › Color, Budget › the pencil; an attachment's sources; voice in the expense sheet | Each opens inside the same sheet (a second screen with a back arrow, or in place), never a sheet on top of another. Every sheet opens and closes with the same gentle motion |

## 9. Sync

| # | Step | Expected |
|---|---|---|
| 9.1 | Sync with others › Join a group: deny the camera | "Allow the camera?" opens once with Open settings. The panel keeps an Open settings button and the prompt doesn't loop |
| 9.2 | With a second device or emulator: invite, join over Wi-Fi, add an expense on each **before** syncing, then sync | Both sides show both expenses, none is lost. An expense deleted on one side stays deleted on both. A deleted group stays deleted |
| 9.3 | Shared group page | A round sync button next to search; after a failed exchange it shows "!" in amber |
| 9.4 | Wi-Fi sync with a phone still on 2.4.x | 2.4.1 and later refuse with "update Caravella on both devices"; a 2.4.0 phone doesn't erase this phone's payments |
| 9.5 | Google Drive (Play build, two devices on the same account): Settings › Sync › Sync devices on both, add an expense on each, Sync now | "Sync now" says what was received and sent; both devices show all the groups and both expenses, with no "shared with you" welcome. Photos stay on the device they were added on |

## 10. Accessibility

The automated part runs in CI: `./validate_accessibility.sh` (pattern guards), `test/accessibility_test.dart`, `test/accessibility_localization_test.dart` and `test/a11y/accessibility_guidelines_test.dart` (tap targets, labels and contrast on the main screens at 100% and 200% text) plus `packages/caravella_core_ui/test/themes/contrast_test.dart` (every colour pair of both themes). Run them locally first:

```bash
./validate_accessibility.sh
(cd packages/caravella_core_ui && flutter test test/themes/contrast_test.dart)
```

Then the manual part, on the device:

| # | Step | Expected |
|---|---|---|
| 10.1 | `./nrt_a11y_check.sh $DEV` on Home, the group page (each tab), the expense form, the currency and budget sheets, Settings | No **unlabeled** tappable element, no tap target under 48 dp, and no button TalkBack reads but **can't activate**. The script lists any it finds |
| 10.2 | Large text: `adb -s $DEV shell settings put system font_scale 2.0`, then repeat the tour of sections 1, 3, 4 and 5 | Nothing is cut off or overlaps and nothing turns into "…" where it matters (amounts never). Figures stack instead of shrinking. Reset with `font_scale 1.0` |
| 10.3 | Dark mode: `adb -s $DEV shell cmd uimode night yes`, same tour. Switch it once **with a sheet open** (the expense form) | Text, rings, bars and dotted links stay readable. Budget amber isn't harsh. An open sheet follows the theme too |
| 10.4 | TalkBack (on a device that has it: Settings › Accessibility › TalkBack), swipe through the group page and the expense form | Each element is read in a sensible order with a meaningful label: the Today card reads the budget, an expense row reads its receipt amount, and the "in kr" link reads "Type the amount in kr" |
| 10.5 | Navigate with a keyboard (`adb shell input keyevent 61` = Tab) through the expense form | Focus moves in reading order and is visible |

## 11. Builds and devices

| # | Step | Expected |
|---|---|---|
| 11.1 | Run the main steps (1, 3.1, 3.4, 6.2) on an Android 14 and an Android 16 emulator, and on a real phone | Same results everywhere |
| 11.2 | Android 10 or 11 (minSdk is 29): cold start and resume | The launch screen shows and Home opens; a moment in the system's theme on resume is expected there |
| 11.3 | F-Droid build (`./build_variant.sh foss`, then a release build): install, cold start, add an expense with a photo | It starts; Photo instead of Scan on Home; no Google sign-in, Drive or Nearby anywhere |
| 11.4 | Android 16+: Settings › Privacy › the App Functions toggle on and off, checking `adb -s $DEV shell dumpsys app_function \| grep -A3 caravella` | The functions (add an expense, list groups, totals, recent expenses) are listed and enabled only while the toggle is on. Gemini itself calls them only once Caravella is enrolled in Google's programme |

## Report

Copy this table into the rc's PR or issue and fill it in:

```
NRT vX.Y.Z-rc.N — device, Android version, date
| Section | Result | Notes |
|---|---|---|
| 0 Upgrade from 2.4 | | |
| 1 Home | | |
| 2 Groups | | |
| 3 Expenses | | |
| 4 Second currency | | |
| 5 Budget | | |
| 6 Balances | | |
| 7 Statistics | | |
| 8 Settings | | |
| 9 Sync | | |
| 10 Accessibility | | |
| 11 Builds and devices | | |
```

Add a row to the right section above whenever a release adds a feature worth checking by hand, and remove rows for features that are gone.
