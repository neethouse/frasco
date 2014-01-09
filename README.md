# frasco

Test environment manager for iOS simulator.

## Installation

    $ gem install frasco

Execute `setup` subcommand.

    $ frasco setup

## Create Snapshot of Test Environment 

### 1. Backup the current iOS simulator environment and clear

	$ frasco stash
	
If iOS simulator is running, execute with `-f` or `--quit` option.
   
### 2. Run iOS simulator, and make environment do as you wish

    $ frasco simulator run
   
Example: Register Twitter accounts.

If you need a clean environment, you do not need to do anything.

### 3. Save the snapshot

	$ frasco save MySnapshot
	
### 4. Cleanup and restore 1st step's backup

	$ frasco cleanup -f
	

## Test Using the Snapshot

### 1. Restore the snapshot

	$ frasco up MySnapshot

`up` subcommand backup the current environment before restoration.

### 2. Test on iOS simulator

Test by Xcode or xcodebuild, or manually…

### 3. Cleanup and restore 1st step's backup

	$ frasco cleanup -f


## Use Snapshot Archive

### 1. Archive snapshot

    $ frasco archive MySnapshot ArchivedMySnapshot.frasco-snapshot

Created "ArchivedMySnapshot.frasco-snapshot" archive file.

### 2. Restore archived snapshot

    $ frasco up-archive ArchivedMySnapshot.frasco-snapshot

### 3. Test on iOS simulator

Test by Xcode or xcodebuild, or manually…

### 4. Cleanup and restore 2nd step's backup

    $ frasco cleanup -f

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

