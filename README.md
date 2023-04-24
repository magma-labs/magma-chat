# MagmaChat

MagmaLabs presents the best ChatGPT-style interface for GPT, written in Rails 7 with CableReady and StimulusReflex!
## Requirements & Setup

* Ruby 3.2.1

* Requires Postgres and Redis to be running

* Run `rails db:setup` to create the database

* Long-term memory for bots requires Marqo, an open-source, multi-modal vector search engine that you can download and run locally using Docker. More information at https://www.marqo.ai/

### OpenAI API

Make sure you have `OPENAI_ACCESS_TOKEN` environment variable set. (Developers, use a `.env` file in the root of the project.)

### Google Oauth

Right now the only authentication method supported is Google Oauth. You'll need `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` environment variables set.

### Admin User

Admin privileges are granted simply with the `admin` boolean attribute on `User`. There is no admin UI at the moment, so if you want to give your user admin rights, do it via the console.

### Configuring Bots

Once you have admin rights, you'll be able to access `/bots` to create additional bots beyond just Gerald, the default GPT Assistant that's created automatically. Note that bots must be published in order to show up in the new chat screen for non-admin users. Draft bots show up to admin users so that they can be tested and refined prior to publication.

Type /debug from any chat input to toggle visibility of hidden messages containing inline instructions to the bots from the platform.

## Contributors

We are actively looking for contributors to the project, but must advise you that by submitting a Pull Request, you disavow any rights or claims to any changes
submitted to the MagmaChat project and assign the copyright of those changes to Obie Fernandez & WeAreMagma Group, Inc..

Should you be unable or unwilling to transfer those rights (as your employment agreement with your employer may prohibit such action), we advise against submitting a pull request. Instead, kindly open an issue and leave the task to be undertaken by another party. This is a common practice for such projects, rather than an exceptional occurrence.

This section is essentially a legalistic expression conveying that "If you submit a PR to us, that code becomes our property". In actuality, this is what most people intend to happen 99.9% of the time, and we hope that it does not deter you from making contributions to the project.
