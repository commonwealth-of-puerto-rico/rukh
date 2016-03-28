Rukh
======

![Rukh](/app/assets/images/179px-Edward_Julius_Detmold49.jpg)

[Dependency Status]: https://gemnasium.com/elgalu/boolean_class


Originally developed for the Environmental Quality Board to keep an accounting of out-standing debts specifically those resulting from bounced checks. Parallel accounting of these was required for these to allow for the closing of the fiscal year. Previously all accounting for these out-standing debts was kept track on a Excel file on a single computer. 

This project has as it's goals the following:

1. Create a persistent database store for the accounting of out-standing debts.
2. Allow easy monitoring of said debts.
3. Allow for importing of data (from csv exported from excel file or other csv source).
4. Present an API for other agencies (particularly the permit agency) to connect to and report outstanding debts.

A further goal is:

- Automatic generation of Mailers for collection efforts.
- Tracking of payment plans.

Due to the expertise found on the EQB (Environmental Quality Board) was limited to Windows this app needed to run on Windows<sup>1</sup>, thus a Jruby/Tomcat stack was used.

__Status__
Presently the application creates a persistent database for accounting of debts, exporting of data to CSV and Excel & generates mailers. 
The API and the import function are pending.

__Set Up__
The application contains documentation on how it was set up including the whole stack and even a proxy for using https. These instructions are under the route `/dev` off the main application. You can also search for the Markdown files in `app/views/static_pages`.

__Pre-deploy__

Before being able to deploy and create a War file you must generate all the secret files if you haven't generated yet. 

Additionally, you must create the database if it doesn't exist (`rake db:create && rake db:migrate`), and the information file with the configuration for connecting to it.

To generate the `secret_key_base` in the `secrets.yml` file use `rake secret`.

1. config/database.yml.txt -> database.yml
2. config/secrets.yml.txt -> secrets.yml

Devise requires a secret at: config/initializers/devise.rb for `config.secret_key` there is a comment on the file but replace the key.

Note: there are rake tasks that have been added to simplify the pre-deploy process and development machine set-up.

You might also need to generate the bin directory w/ `rake rails:update:bin`


__Testing Emails__

The gem [MailCatcher](mailcatcher.me) was used to test email sending locally. It doesn't work on JRuby. But you can start it from normal Ruby using RVM. I highly recommend using an RVM gemset and wrapper for MailCatcher as it tends con conflict with gems required by Rails.

__Name__
Rukh was originally 'RucPoc -- registro único de cuentas por cobrar' (literally 'single registry for out-standing debts') but now it's just a meaningless-name associated with the [Rukh](http://en.wikipedia.org/wiki/Roc_(mythology)) from Arabian Nights. 

__Documentation__
Rukh has documentation in the platform under the `/dev` link.
Additional documentation is found in the tests under the /spec folder in Rspec.

Code Organization:
This app was developed using **BDD** and **Hexagonal Rails** design, that is the buisness logic should be as much as possilbe in the `/lib` folder and talk to the controller or model through self-contained method calls. Search YouTube for ["GoRuCo 2012 Hexagonal Rails by Matt Wynne"](https://youtu.be/CGN4RFkhH2M) for more details on Hexagonal Rails.
Please note the `/lib` directory is not automatically reloaded in development. 

__License:__
The code is under GPL v3.

<sup>1</sup> While Rukh works on a Windows stack a JRuby (`TCPSocket.open('ipaddrss', 25)`) bug prevented email delivery using SMTP. The final application was hosted on Linux, Windows was used as a test bed. An issue with the bug was opened on JRuby github page. This was an unfortunate event since JRuby was picked because of a need to run it on Windows. 

image: [wikimedia commons](http://en.wikipedia.org/wiki/File:Edward_Julius_Detmold49.jpg): Charles Maurice Detmold (1883-1908)

