# Alces Flight Hangar

A tool for the consistent creation of complex CloudFormation templates.

## Prerequisites

 * Ruby 2.2.0+
 * Bundler

## Installation

```
git clone https://github.com/alces-software/flight-hangar.git
cd flight-hangar
bundle install --path=vendor
```

## Operation

Copy your database files to the `db/` subdirectory:

```
cp -R /path/to/db db/
```

Render all your templates to the `output` subdirectory:

```
bin/hangar render --all
```

Render a template to standard output:

```
bin/hangar render mytemplate
```

## Contributing

Fork the project. Make your feature addition or bug fix. Send a pull request. Bonus points for topic branches.

## Copyright and License

GPLv3+ License, see [LICENSE.txt](LICENSE.txt) for details.

Copyright (C) 2016 Alces Software Ltd.

Alces Flight Hangar is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Alces Flight Hangar is made available under a dual licensing model whereby use of the package in projects that are licensed so as to be compatible with GPL Version 3 may use the package under the terms of that license. However, if GPL Version 3.0 terms are incompatible with your planned use of this package, alternative license terms are available from Alces Software Ltd - please direct inquiries about licensing to [licensing@alces-software.com](mailto:licensing@alces-software.com).
