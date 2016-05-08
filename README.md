# DVSA Auto Booker

This small Ruby script scrapes the DVSA appointment cancellations site and automatically re-books practical tests if a more appropriate one becomes available. The tool will also automatically re-book if a more desirable (i.e., closer to your latest desired date) slot becomes available.

**Note:** Repeated scrapings within a short time frame can trigger DVSA's IP-based CAPTCHA.

## Installation

To install the dependencies:

```
bundle install
```

### PhantomJS

PhantomJS must be installed on your machine and the `phantomjs` executable on your PATH.

For Ubuntu/Debian, run `sudo apt-get install phantomjs`

For Mac OS X and Windows, download from the [PhantomJS static build page](http://phantomjs.org/download.html).

### Configuration

Before running the script, a `.env` file should be created (or the appropriate environment variables set). See below for an example `.env` file:

```
DVSA_DRIVING_LICENSE_NUMBER=driving_license_number
DVSA_APPLICATION_REF_NUMBER=application_reference_number

TEST_CENTRE_DESIRED=name of test centre
TEST_EARLIEST_DATE=earliest date for test eg, 2016/07/04
TEST_LATEST_DATE=latest date for test eg, 2016/07/14
```

## Running the script

```
rake auto_book
```

### Running on a schedule

As described in `config/schedule.rb`, a Crontab can be setup to execute `rake auto_book` a few times per hour by executing:

```
whenever --update-crontab
```