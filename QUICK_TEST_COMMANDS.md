# Broadcaster Crash Fix - Quick Test Commands

Copy-paste ready commands for testing the v1.0.31+31 build.

---

## Device Setup

```bash
# Check if Samsung is connected
adb devices -l

# Enable USB Debugging on Samsung (do on device):
# Settings → About phone → tap "Build number" 7x → Developer Options → USB Debugging

# Restart adb daemon if device not showing
adb kill-server && adb start-server && sleep 2 && adb devices -l
```

---

## Install APK

```bash
# Option 1: Via Flutter
cd ~/Documents/developer/brawe-app
flutter run

# Option 2: Via ADB directly
adb install ~/Documents/developer/brawe-app/build/app/outputs/flutter-apk/app-release.apk

# Verify installation
adb shell pm list packages | grep brawe
```

---

## Monitoring Logs

```bash
# Terminal 1: Clear and monitor broadcaster state changes
adb logcat -c
adb logcat -s "broadcaster"

# Terminal 2: Monitor native crashes (in new terminal)
adb logcat "*:F" "*:E"

# Terminal 3: Monitor ANR warnings (in new terminal)
adb logcat "*:W" | grep -i "anr"

# Or single command to watch all three:
adb logcat | grep -E "broadcaster|CRASH|FATAL|SIGSEGV|EGL|ANR"
```

---

## Test Scenario Commands

### Test 1: Rapid Go Live → Stop

```bash
# Open broadcaster screen, then run this script:
for i in {1..5}; do
  echo "Cycle $i: Tap Go Live in 2 seconds..."
  sleep 2
  adb shell am broadcast -a "com.braweapp.test.toggle_stream" 2>/dev/null || echo "UI: Tap Go Live"
  sleep 3
  adb shell am broadcast -a "com.braweapp.test.stop_stream" 2>/dev/null || echo "UI: Tap Stop"
  sleep 1
done

# Or manually: Tap "Go Live" → Stop rapidly in UI
```

### Test 2: Background/Foreground Cycling

```bash
# Cycle app 5 times while streaming
for i in {1..5}; do
  echo "Cycle $i..."
  adb shell am broadcast -a "com.braweapp.test.toggle_stream" 2>/dev/null || echo "Tap Go Live"
  sleep 3
  adb shell input keyevent 3  # Home (background)
  sleep 2
  adb shell am start -n com.braweapp/com.braweapp.MainActivity  # Foreground
  sleep 1
done
```

### Test 3: Check Device Memory

```bash
# Monitor memory while streaming
watch -n 1 'adb shell "free -m"'

# Or one-shot:
adb shell "free -m"
```

### Test 4: Capture Full Device Log

```bash
# Save all logs to file (useful for debugging crashes)
adb logcat -d > ~/brawe_test_log.txt
echo "Logs saved to ~/brawe_test_log.txt"

# View saved logs
cat ~/brawe_test_log.txt | grep -i "broadcaster\|crash\|error"
```

### Test 5: Get Device Info

```bash
# Check Android version, model, etc.
adb shell getprop ro.build.version.release
adb shell getprop ro.product.model
adb shell getprop ro.product.brand
```

---

## Debugging Commands

```bash
# Get app version installed
adb shell dumpsys package com.braweapp | grep version

# Check app storage usage
adb shell du -sh /data/app/com.braweapp*

# Restart app
adb shell am force-stop com.braweapp
adb shell am start -n com.braweapp/com.braweapp.MainActivity

# Kill all adb processes (nuclear option)
adb shell am kill-all

# Monitor CPU while streaming
adb shell "top -m 10 -n 1" | head -20

# Check battery drain
adb shell dumpsys battery
```

---

## Play Console Upload

```bash
# Verify AAB exists
ls -lh ~/Documents/developer/brawe-app/build/app/outputs/bundle/release/app-release.aab

# Size should be ~129MB, built on 2026-07-17
file ~/Documents/developer/brawe-app/build/app/outputs/bundle/release/app-release.aab
```

**Then:**
1. Open https://play.google.com/console
2. Select Brawe app
3. Testing → Internal Testing → Create new release
4. Upload the AAB file
5. Add release notes (see BROADCASTER_CRASH_FIX_DEPLOYMENT_GUIDE.md)
6. Click "Review release" → "Start internal testing"

---

## Quick Cleanup

```bash
# Stop emulator if running
adb emu kill

# Restart adb
adb kill-server && adb start-server

# Clear app cache (keeps app, removes user data)
adb shell pm clear com.braweapp

# Uninstall app completely
adb uninstall com.braweapp
```

---

## Success Indicators (Check Logs)

✅ Should see these log entries:
```
I/broadcaster: [state_change] idle → requestingPermissions
I/broadcaster: [state_change] requestingPermissions → initializing
I/broadcaster: [state_change] initializing → previewReady
I/broadcaster: [state_change] previewReady → startingStream
I/broadcaster: [state_change] startingStream → streaming
```

❌ Should NOT see:
```
FATAL EXCEPTION
SIGSEGV
GL_INVALID_OPERATION
EGL error
ANRManager: Application Not Responding
```

---

## One-Command Full Test (Automated)

```bash
#!/bin/bash
set -e

echo "=== Broadcaster Crash Fix Test Suite v1.0.31+31 ==="
echo

# 1. Verify device connected
echo "[1/5] Checking device..."
adb devices -l
echo

# 2. Install app
echo "[2/5] Installing app..."
adb install -r ~/Documents/developer/brawe-app/build/app/outputs/flutter-apk/app-release.apk
sleep 3

# 3. Start app
echo "[3/5] Launching broadcaster..."
adb shell am start -n com.braweapp/com.braweapp.MainActivity
sleep 5

# 4. Clear and monitor logs
echo "[4/5] Monitoring for crashes (30 seconds)..."
adb logcat -c
adb logcat -d > /tmp/brawe_pretest.txt  # baseline

sleep 30

# 5. Capture logs and check for crashes
echo "[5/5] Analyzing logs..."
adb logcat -d > /tmp/brawe_posttest.txt

CRASHES=$(grep -c "FATAL\|SIGSEGV\|GL_INVALID\|EGL error" /tmp/brawe_posttest.txt || echo "0")
STATE_CHANGES=$(grep -c "state_change" /tmp/brawe_posttest.txt || echo "0")

echo
echo "=== Test Results ==="
echo "State transitions detected: $STATE_CHANGES"
echo "Crashes detected: $CRASHES"

if [ "$CRASHES" -eq 0 ]; then
  echo "✅ TEST PASSED - No crashes detected"
else
  echo "❌ TEST FAILED - Crashes detected!"
  echo "See /tmp/brawe_posttest.txt for details"
fi

# Save detailed report
cat /tmp/brawe_posttest.txt | grep -E "broadcaster|FATAL|ERROR" > /tmp/brawe_test_report.txt
echo
echo "Full report: /tmp/brawe_test_report.txt"
```

**Run it:**
```bash
chmod +x ~/brawe_test.sh
~/brawe_test.sh
```

---

## File Locations Reference

| Item | Path |
|------|------|
| APK | `~/Documents/developer/brawe-app/build/app/outputs/flutter-apk/app-release.apk` |
| AAB | `~/Documents/developer/brawe-app/build/app/outputs/bundle/release/app-release.aab` |
| Code changes | `~/Documents/developer/brawe-app/lib/ui/broadcaster/widgets/broadcaster_screen.dart` |
| Diff patch | `/tmp/broadcaster_diff.patch` |
| Tests | `~/Documents/developer/brawe-app/test/ui/broadcaster/widgets/broadcaster_state_test.dart` |
| Deployment guide | `~/Documents/developer/brawe-app/BROADCASTER_CRASH_FIX_DEPLOYMENT_GUIDE.md` |

---

**Status**: ✅ Ready for testing  
**Version**: 1.0.31+31  
**Last updated**: 2026-07-17
