# Non-regression tests (NRT)

Manual non-regression pass run on the **release candidate's own APK**, the staging build from the `vX.Y.Z-rc.N` pre-release, before it goes to testers or to the stores. The unit and widget tests (`flutter test`, CI) catch logic regressions. This pass catches what they can't: the real build, real navigation, the system's dialogs, the keyboard, TalkBack and large text.

Run it on an emulator, or on a phone that is not a personal one, since it clears the app's data. One pass takes about an hour. Record each step as **OK** or **KO** in the [report](#report) and attach a screenshot of every KO.

## Setup

```bash
DEV=emulator-5560                      # adb device to use
APK=Caravella-2.5.0-rc.1-staging.apk   # from the pre-release's assets
PKG=io.caravella.egm.staging

gh release download v2.5.0-rc.1 -R calca/caravella -p '*.apk' -D /tmp/rc
adb -s $DEV install -r /tmp/rc/$APK
adb -s $DEV shell pm clear $PKG        # fresh start: no groups, no settings
adb -s $DEV shell settings put system font_scale 1.0
adb -s $DEV shell cmd uimode night no
```

Screenshots: `adb -s $DEV exec-out screencap -p > shot.png`.

## 1. First start and Home

| # | Step | Expected |
|---|---|---|
| 1.1 | Open the app on a fresh install | Onboarding, then the empty Home with "create a group". No crash, no permission prompt at start |
| 1.2 | Create a first group from Home | The wizard opens (see 2.1). Back on Home, the group's card shows its total, today, the wave chart and recent expenses |
| 1.3 | Home shortcuts: Scan (Play) or Photo (F-Droid), Voice, Map, Search | Each one opens. Deny the camera or microphone once: a dialog with **Open settings**, not a toast |

## 2. Groups

| # | Step | Expected |
|---|---|---|
| 2.1 | Wizard: type Travel, a name, dates, currency, background (photo, colour, none), participants, categories | The preview card updates as you type. Continue stays off without a name. The new group opens |
| 2.2 | Settings › General: rename, change the dates, change the type and background, then back | The changes are saved on back, and the header shows them |
| 2.3 | General with an empty name, then back | Back is blocked, the field is focused and a toast explains why |
| 2.4 | Archive the group, find it in Groups › Archived, unarchive it | It moves between the tabs. Home no longer shows it while archived |
| 2.5 | Delete a group | Confirmation, then it is gone from Groups and Home |

## 3. Expenses

| # | Step | Expected |
|---|---|---|
| 3.1 | Quick sheet: amount, description, paid by, category, Add | Saved. Totals, Today and the list update |
| 3.2 | Quick sheet, then **More details** | The full page opens with what was typed, and the keyboard stays down |
| 3.3 | Full form: date, place (search and current location), note, two attachments | All saved and shown when the expense is reopened |
| 3.4 | Edit an expense: change the amount and payer | The list and balances update |
| 3.5 | Delete an expense | Confirmation, then it is gone, and the totals drop |
| 3.6 | Search from the group and from Home | Matches are highlighted and tapping one opens the expense |
| 3.7 | Voice: "20 euro coffee", then "20 euro" alone | The first is saved. The second opens the form to add the name, and nothing is lost |

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
| 5.2 | Group page, Today card | A ring after the amount, on its line: grey within the budget, full muted amber when over, never red |
| 5.3 | Tap Today | The budget sheet: today, the period with its bar, per day and average. Monthly, weekly and daily budgets also show the three periods before |
| 5.4 | Spend over today's share | The ring is full amber and the sheet says how much over |
| 5.5 | Remove the budget | The ring is gone and Today no longer opens a sheet |

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

## 9. Sync

| # | Step | Expected |
|---|---|---|
| 9.1 | Sync with others › Join a group: deny the camera | "Allow the camera?" opens once with Open settings. The panel keeps an Open settings button and the prompt doesn't loop |
| 9.2 | With a second device or emulator: invite, join over Wi-Fi, add an expense on each, sync | Both sides show both expenses. A deleted group stays deleted |

## 10. Accessibility

The automated part runs in CI: `./validate_accessibility.sh` (pattern guards), `test/accessibility_test.dart`, `test/accessibility_localization_test.dart` and `test/a11y/accessibility_guidelines_test.dart` (tap targets, labels and contrast on the main screens at 100% and 200% text) plus `packages/caravella_core_ui/test/themes/contrast_test.dart` (every colour pair of both themes). Run them locally first:

```bash
./validate_accessibility.sh
(cd packages/caravella_core_ui && flutter test test/themes/contrast_test.dart)
```

Then the manual part, on the device:

| # | Step | Expected |
|---|---|---|
| 10.1 | `./nrt_a11y_check.sh $DEV` on Home, the group page (each tab), the expense form, the currency and budget sheets, Settings | No **unlabeled** tappable element and no tap target under 48 dp. The script lists any it finds |
| 10.2 | Large text: `adb -s $DEV shell settings put system font_scale 2.0`, then repeat the tour of sections 1, 3, 4 and 5 | Nothing is cut off or overlaps and nothing turns into "…" where it matters (amounts never). Figures stack instead of shrinking. Reset with `font_scale 1.0` |
| 10.3 | Dark mode: `adb -s $DEV shell cmd uimode night yes`, same tour | Text, rings, bars and dotted links stay readable. Budget amber isn't harsh |
| 10.4 | TalkBack (on a device that has it: Settings › Accessibility › TalkBack), swipe through the group page and the expense form | Each element is read in a sensible order with a meaningful label: the Today card reads the budget, an expense row reads its receipt amount, and the "in kr" link reads "Type the amount in kr" |
| 10.5 | Navigate with a keyboard (`adb shell input keyevent 61` = Tab) through the expense form | Focus moves in reading order and is visible |

## Report

Copy this table into the rc's PR or issue and fill it in:

```
NRT vX.Y.Z-rc.N — device, Android version, date
| Section | Result | Notes |
|---|---|---|
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
```

Add a row to the right section above whenever a release adds a feature worth checking by hand, and remove rows for features that are gone.
