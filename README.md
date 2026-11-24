# PC Refresher

A set of Windows batch scripts that clean temporary files, Windows Update leftovers, and browser caches, then show how much disk space was recovered. A companion script schedules the cleanup as a weekly Windows task that runs with full administrator rights, so it never prompts.

> **Warning:** files are deleted permanently. They do not go to the Recycle Bin, and the Recycle Bin itself is emptied.

## Features

- Clears Windows temp, the Windows Update download cache, and error report queues
- Clears each user's temp folder, D3D shader cache, internet cache, and Chrome and Edge caches
- Removes thumbnail cache files and empties the Recycle Bin
- Stops and restarts Windows Update services so their locked files can be removed
- Shows a colored progress bar and a banner while it runs
- Reports the free space before and after, and the space recovered
- Writes a summary line to `C:\Windows\Temp\cleanup_log.txt`

## Files

| File | Purpose |
|------|---------|
| `refresher.bat` | The cleanup script. Run it by hand or from Task Scheduler. |
| `create_task.bat` | Creates the weekly scheduled task that runs `refresher.bat`. |
| `remove_task.bat` | Deletes the scheduled task. |

## Requirements

- Windows 10 or Windows 11
- Administrator rights
- Windows Terminal or a recent console for colors (the scripts enable color support automatically)

## Quick start

### 1. Run a cleanup now

Right-click `refresher.bat` and choose **Run as administrator**. Press any key when it finishes.

### 2. Schedule it weekly

Right-click `create_task.bat` and choose **Run as administrator**. When prompted, enter the folder that contains `refresher.bat`, for example:

```
L:\Python\projects\pc-refresher
```

You can also pass the folder or file path and the run time on the command line:

```
create_task.bat "L:\Python\projects\pc-refresher" 02:30
```

The task is named **PC Refresher** and is set to:

- Run every Sunday at 03:00 (or the time you give)
- Run as `SYSTEM` with highest privileges, so no password or UAC prompt is needed
- Stop automatically after 1 hour
- Run at the next opportunity if the PC was off at the scheduled time

Running `create_task.bat` again replaces the existing task, so it never creates duplicates.

### 3. Remove the schedule

Right-click `remove_task.bat` and choose **Run as administrator**.

## Viewing the task

Open Task Scheduler, then click **Task Scheduler Library**. The task appears as **PC Refresher**. To check the details from a command prompt:

```
schtasks /query /tn "PC Refresher" /v /fo list
```

To test the task without waiting for Sunday, right-click it in Task Scheduler and choose **Run**, or run:

```
schtasks /run /tn "PC Refresher"
```

## Logs

Each run appends a line to:

```
C:\Windows\Temp\cleanup_log.txt
```

It records the start time, the amount recovered, and the free space before and after.

## Customizing

- **Add a location:** in `refresher.bat`, add a line like `call :wipe "PATH" "Description"` in the section you want.
- **Change the schedule:** run `create_task.bat` again with a different time, or edit the task in Task Scheduler.
- **Change the frequency:** edit the `/sc weekly /d SUN` part of `create_task.bat`.

## Notes and limits

- Locked files, such as browser files in use, are skipped. This is harmless.
- Only the `Default` Chrome and Edge profiles are cleaned.
- The scripts intentionally leave `C:\Windows\Installer`, `WinSxS`, `Prefetch`, and `Windows.old` alone. Use Disk Cleanup for `Windows.old`.
- Test on one machine before rolling out to others.

## License

Add a license here, for example MIT.