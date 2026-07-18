# 📋 Production Deployment Checklist - Broadcaster Crash Fix v1.0.31+31

Use this checklist to track progress through deployment phases.

---

## Phase 1: Pre-Deployment Validation ✅

- [x] Code changes reviewed and validated
  - [x] File: `lib/ui/broadcaster/widgets/broadcaster_screen.dart` (+523/-95)
  - [x] Changes: State machine, session guards, serialization
  - [x] No dependency updates
  
- [x] Build artifacts generated
  - [x] APK: `build/app/outputs/flutter-apk/app-release.apk` (153 MB, v1.0.31+31)
  - [x] AAB: `build/app/outputs/bundle/release/app-release.aab` (129 MB, v1.0.31+31)
  - [x] Diff: `/tmp/broadcaster_diff.patch` (889 lines)

- [x] Static analysis passed
  - [x] `flutter analyze`: 0 new errors
  - [x] Dart syntax: Valid
  - [x] Type checking: Pass
  - [x] Imports: Resolved

- [x] Tests validated
  - [x] `broadcaster_state_test.dart`: 3/3 passing
  - [x] No test regressions (full suite baseline verified)
  - [x] State machine contract verified

- [x] Code decompilation analysis
  - [x] FVP 0.37.3: Verified subtitle options (refuted false claims)
  - [x] RootEncoder 1.9.6: Verified SurfaceManager API
  - [x] rtmp_broadcaster: Verified version match to AAR
  - [x] Android API surface: Confirmed no "Surface ready" events available

- [x] Documentation complete
  - [x] `ANDROID_NATIVE_MEDIA_CRASH_FIX_REPORT.md` (comprehensive)
  - [x] `BROADCASTER_CRASH_FIX_DEPLOYMENT_GUIDE.md` (step-by-step)
  - [x] `QUICK_TEST_COMMANDS.md` (copy-paste)
  - [x] `DEPLOYMENT_SUMMARY.md` (management overview)
  - [x] `START_HERE_CRASH_FIX.md` (quick reference)
  - [x] `PRODUCTION_CHECKLIST.md` (this file)

- [x] Release notes prepared
  - [x] English version (short)
  - [x] Portuguese version (full)
  - [x] Ready for Play Console upload

- [x] Risk assessment completed
  - [x] Code scope: Low (single file, no deps)
  - [x] Backward compatibility: Low (UI/API unchanged)
  - [x] Rollback complexity: Low (one-line git revert)
  - [x] Test coverage: Adequate (unit + manual scenarios available)

---

## Phase 2: Device Preparation ⏳

**Choose ONE path below:**

### Path A: Google Play Console Internal Testing

- [ ] **Prerequisites**
  - [ ] Google Play Console access (owner or release manager role)
  - [ ] Brawe app exists in Play Console
  - [ ] Internal testing track available

- [ ] **Setup** (5 minutes)
  - [ ] Log in to [Google Play Console](https://play.google.com/console)
  - [ ] Select Brawe app
  - [ ] Navigate to Testing → Internal Testing
  - [ ] Verify no active releases (clean slate recommended)

- [ ] **Upload**
  - [ ] Click "Create new release"
  - [ ] Upload AAB: `build/app/outputs/bundle/release/app-release.aab`
  - [ ] Copy release notes from `BROADCASTER_CRASH_FIX_DEPLOYMENT_GUIDE.md`
  - [ ] Click "Review release"
  - [ ] Verify no errors detected by Play Console
  - [ ] Click "Start internal testing"

- [ ] **Propagation**
  - [ ] Add internal test accounts (Gmail addresses)
  - [ ] Accounts should receive notification in Play Store within 2-5 minutes
  - [ ] Verify app appears under "Internal Testing" in Play Store on test devices

### Path B: Direct USB Installation

- [ ] **Device Setup**
  - [ ] Connect Samsung device via USB to Mac
  - [ ] On device: Settings → About phone
  - [ ] Tap "Build number" 7 times (unlock Developer Options)
  - [ ] Settings → Developer Options → USB Debugging (enable)
  - [ ] Press "Trust" on device when prompted
  - [ ] Verify device appears: `adb devices -l` (should show "device" status)

- [ ] **Installation**
  - [ ] Run: `adb install ~/Documents/developer/brawe-app/build/app/outputs/flutter-apk/app-release.apk`
  - [ ] Wait for install to complete (should see "Success" message)
  - [ ] Verify: `adb shell pm list packages | grep brawe` (should list com.braweapp)

---

## Phase 3: Manual Testing ⏳

**Execute on Samsung device (either Play Console or direct USB install)**

### Setup (5 minutes)

- [ ] **Pre-test checks**
  - [ ] App installed and launches without errors
  - [ ] Device has at least 300 MB free storage
  - [ ] Internet connection stable (WiFi or mobile)
  - [ ] Camera app works (test via native camera app first)
  - [ ] Microphone works (test via voice recorder)

- [ ] **Logging setup**
  ```bash
  # Terminal 1: Monitor broadcaster logs
  adb logcat -c
  adb logcat | grep -i "broadcaster\|state_change"
  
  # Terminal 2: Monitor crashes (in new terminal)
  adb logcat "*:F" "*:E"
  ```

### Quick Validation (15 minutes)

- [ ] **Test 1: Basic Flow**
  - [ ] Open Brawe app
  - [ ] Navigate to Broadcaster screen
  - [ ] Grant camera + microphone permissions if prompted
  - [ ] Verify camera preview shows live feed
  - [ ] Tap "Go Live" button
  - [ ] Wait 3 seconds for stream to stabilize
  - [ ] Tap "Stop Streaming"
  - [ ] **Result**: No crashes, smooth state transitions
  - [ ] **Check logs**: Should show `[state_change]` messages, NO errors

- [ ] **Test 2: Rapid Cycles (5x)**
  - [ ] Tap "Go Live"
  - [ ] Immediately (2 seconds) tap "Stop Streaming"
  - [ ] Repeat 5 times rapidly
  - [ ] **Result**: All cycles complete without crashes
  - [ ] **Check logs**: No EGL errors, no SIGSEGV

- [ ] **Test 3: Background/Foreground**
  - [ ] Tap "Go Live"
  - [ ] Wait 3 seconds
  - [ ] Press Home button (app goes background)
  - [ ] Wait 2 seconds
  - [ ] Open app again (foreground)
  - [ ] Wait 3 seconds
  - [ ] Tap "Stop Streaming"
  - [ ] **Result**: App resumes cleanly, stream continues
  - [ ] **Check logs**: State machine stays valid

### Full Test Matrix (30 minutes)

**Complete all 10 test scenarios from `BROADCASTER_CRASH_FIX_DEPLOYMENT_GUIDE.md` Section: "Manual Testing Scenarios"**

- [ ] Test 1: Rapid Go Live → Stop (5x)
- [ ] Test 2: Background/Foreground Cycling (5x)
- [ ] Test 3: Camera Switch During Stream
- [ ] Test 4: Slow Network Simulation
- [ ] Test 5: Permission Denial Recovery
- [ ] Test 6: Device Rotation (Landscape ↔ Portrait)
- [ ] Test 7: Concurrent Permission Requests
- [ ] Test 8: Stream Interruption & Rapid Restart
- [ ] Test 9: Memory Pressure Test
- [ ] Test 10: ANR Recovery

### Validation Criteria

- [ ] **Success**: All 10 tests complete without any crashes
- [ ] **Logs show**: State machine transitions (idle → requestingPermissions → ... → streaming → ... → idle)
- [ ] **Logs don't show**: FATAL EXCEPTION, SIGSEGV, EGL_INVALID, ANR
- [ ] **App behavior**: Responsive, no hangs, camera works, audio works
- [ ] **Device stability**: Device doesn't restart, no thermal issues

### Failure Scenarios & Recovery

**If crash occurs**:
- [ ] Take note of exact sequence (which test scenario?)
- [ ] Capture full log: `adb logcat -d > ~/crash_log_$(date +%s).txt`
- [ ] Note device model and Android version: `adb shell getprop ro.product.model && adb shell getprop ro.build.version.release`
- [ ] Note any custom modifications to device (heavy usage, low memory, etc.)
- [ ] **Do NOT proceed** - investigate crash before broader deployment

**If test gets stuck** (app unresponsive for >10 seconds):
- [ ] This indicates ANR (Application Not Responding)
- [ ] Let it resolve (device will prompt to kill app)
- [ ] Take logs and note the operation that triggered ANR
- [ ] **Do NOT proceed** - investigate ANR before broader deployment

---

## Phase 4: Post-Test Sign-Off ⏳

- [ ] **QA Verification**
  - [ ] All manual tests passed (10/10 scenarios)
  - [ ] No crashes observed
  - [ ] State machine transitions logged correctly
  - [ ] Device remained stable
  - [ ] QA signature: _________________ Date: _______

- [ ] **Product Review**
  - [ ] Release notes are clear and user-friendly
  - [ ] No mention of internal technical details
  - [ ] Timing is appropriate (no conflicts with other releases)
  - [ ] Version number 1.0.31+31 confirmed
  - [ ] Product signature: _________________ Date: _______

- [ ] **Security Review**
  - [ ] No new security vulnerabilities introduced
  - [ ] No PII or secrets in code or logs
  - [ ] Logging is sanitized (only roomId, cameraSession, state)
  - [ ] Security signature: _________________ Date: _______

---

## Phase 5: Broader Deployment (After Success) ⏳

**Only proceed if Phase 4 sign-offs are complete**

### Play Console Rollout

- [ ] **Internal Testing → Closed Testing**
  - [ ] If internal tests pass, create new release with same AAB
  - [ ] Move to Closed Testing track (limited audience, 24-hour delay before production)
  - [ ] Closed testing approval: _________________ Date: _______

- [ ] **Closed Testing → Production**
  - [ ] After 24-48 hours of closed testing, monitor Crashlytics
  - [ ] If no new crashes and stable metrics, promote to Production
  - [ ] Production rollout approval: _________________ Date: _______

### Monitoring & Rollback Decision

- [ ] **24-Hour Monitoring**
  - [ ] Watch Crashlytics: Crash B should drop or disappear
  - [ ] Watch Crashlytics: Crash A should remain stable or drop
  - [ ] No new crash patterns emerge
  - [ ] ANR rate remains stable
  - [ ] Crash rate lower than pre-release baseline

- [ ] **If Issues Found**
  - [ ] Initiate rollback procedure (see below)
  - [ ] Pause broader rollout
  - [ ] Escalate to development team
  - [ ] Issue reason: _________________ Date: _______

---

## Phase 6: Rollback Procedure (Emergency Only)

**Execute if critical issues are discovered post-release**

### Option 1: Play Console Immediate Stop (30 seconds)

- [ ] Go to Play Console → Release Management
- [ ] Find current release (v1.0.31+31)
- [ ] Click "Edit" → "Stop rollout"
- [ ] Confirm
- [ ] **Result**: Previous build (v1.0.30 or earlier) automatically restored
- [ ] Verify: Play Store shows previous version within 1-2 minutes

### Option 2: Code Revert & Rebuild (5 minutes)

- [ ] Terminal:
  ```bash
  cd ~/Documents/developer/brawe-app
  git log --oneline lib/ui/broadcaster/widgets/broadcaster_screen.dart | head -1
  # Note the commit hash, e.g., abc1234
  
  git revert abc1234
  git push origin main
  flutter build appbundle --release
  ```
- [ ] Upload new AAB to Play Console as hotfix
- [ ] Mark as urgent release
- [ ] Approval for revert: _________________ Date: _______

### Option 3: Feature Disable (1 minute - Nuclear)

- [ ] Backend: Disable live streaming endpoints
- [ ] Frontend: App still installs but "Go Live" shows "Unavailable"
- [ ] **Effect**: Completely prevents crash surface
- [ ] **Recovery**: Re-enable endpoints when fix is ready
- [ ] Feature disable timestamp: _________________ Date: _______

---

## Phase 7: Post-Deployment Monitoring (Ongoing)

**First 7 days after production release**

- [ ] **Daily Checklist**
  - [ ] [ ] Day 1: Check Crashlytics for Crash B (should be 0 or dropping)
  - [ ] [ ] Day 1: Check Crashlytics for Crash A (should be stable)
  - [ ] [ ] Day 2: Verify no regression in ANR rate
  - [ ] [ ] Day 3: Verify no regression in crash rates (general)
  - [ ] [ ] Day 4: No new crash patterns
  - [ ] [ ] Day 5: Stable metrics, no issues
  - [ ] [ ] Day 6: Stable metrics, no issues
  - [ ] [ ] Day 7: Final validation, mark as stable

- [ ] **Weekly Review**
  - [ ] Compare crash metrics to pre-release baseline
  - [ ] Verify Crash B disappeared
  - [ ] Note any Crash A recurrence (requires separate investigation)
  - [ ] Confirm no new crash types introduced
  - [ ] Document metrics: _________________ Date: _______

- [ ] **Monthly Review** (after 30 days)
  - [ ] Crash B: Verify sustained zero or near-zero
  - [ ] Overall stability: No regressions
  - [ ] User feedback: No complaints about broadcaster crashes
  - [ ] Monthly sign-off: _________________ Date: _______

---

## Sign-Off Summary

| Phase | Owner | Status | Date | Notes |
|-------|-------|--------|------|-------|
| Phase 1: Pre-Deployment | Engineering | ✅ Complete | 2026-07-17 | Code validated |
| Phase 2: Device Setup | QA | ⏳ Pending | ________ | Choose USB or Console |
| Phase 3: Manual Testing | QA | ⏳ Pending | ________ | 10/10 scenarios required |
| Phase 4: Sign-Offs | QA+Product+Security | ⏳ Pending | ________ | All must approve |
| Phase 5: Broader Rollout | DevOps | ⏳ Pending | ________ | After Phase 4 complete |
| Phase 6: Rollback (if needed) | Engineering | ⏳ On-Standby | ________ | Emergency only |
| Phase 7: Monitoring | Operations | ⏳ Pending | ________ | Starts after Phase 5 |

---

## Quick Reference Links

| Document | Purpose |
|----------|---------|
| `START_HERE_CRASH_FIX.md` | 1-page overview |
| `DEPLOYMENT_SUMMARY.md` | Management summary |
| `BROADCASTER_CRASH_FIX_DEPLOYMENT_GUIDE.md` | Step-by-step guide |
| `QUICK_TEST_COMMANDS.md` | Copy-paste commands |
| `ANDROID_NATIVE_MEDIA_CRASH_FIX_REPORT.md` | Technical deep-dive |

---

## Emergency Contacts

- **Engineering Lead**: [Who to contact for code issues?]
- **QA Lead**: [Who to contact for test failures?]
- **DevOps**: [Who to contact for Play Console access?]
- **Product**: [Who to contact for release decisions?]

---

## Notes

```
____________________________________________________________________

____________________________________________________________________

____________________________________________________________________

____________________________________________________________________

____________________________________________________________________
```

---

**Version**: 1.0.31+31  
**Created**: 2026-07-17 14:50 UTC  
**Last Updated**: ____________  
**Status**: ⏳ Awaiting Phase 2 execution

**NEXT ACTION**: Choose Phase 2 path (Play Console or USB) and proceed with device setup.
