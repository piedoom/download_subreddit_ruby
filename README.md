# Download Subreddit Ruby
A fun script inspired by [Coldsauce's repo](https://github.com/ColdSauce/download_subreddit)

## Installing
Clone the repo by running `git clone https://github.com/piedoom/download_subreddit_ruby`, assuming you have git and ruby already installed

Navigate to the root folder and run `bundle install`

## Using the app

The command line application has a few options.  They are

`-r` or `--reddit`, which specifies the subreddit to grab posts from.  This is required.

`-p` or `--pages`, which specifies when to stop aggregating pages.  This is not required, but is default at 100

`-d` or `--download`, which specifies whether or not to automatically download the imgur images.  This is not required and is currently broken

`-n` or `--name`, which specifies a specific name for the generated files.  This is not required and defaults to automatic naming.

## Examples

The most simple command is as follows:

`ruby sub_downloader.rb -r pics`, which will compile a file of imgur links based on the 100 newest pages of `/r/pics`

All the commands together:

`ruby sub_downloader.rb -r pics -p 500 -n mypics`, which will compile a file of imgur links based on the 500 newest pages of `/r/pics` and name the files `mypics`