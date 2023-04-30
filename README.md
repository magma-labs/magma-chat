# MagmaChat
MagmaLabs presents the best ChatGPT-style interface for GPT, written in Rails 7 with CableReady and StimulusReflex!

## Features
MagmaChat is essentially still a proof of concept, but a lot of showstopper bugs have been shaken out in-house at MagmaLabs where we are using it as our corporate ChatGPT solution.
### Login with Google Oauth
Eventually we should integrate Devise for many more authentication and user management options, but for now you need to sign in using a Google Account.

### Create and manage Bots and Conversations
A chat (aka conversation) is an instance of a chat between a human and a bot. A bot is an anthropomorphized digital persona/autonomous agent configured in MagmaChat and brought to life using OpenAI’s API for chat completion (aka ChatGPT).

The default bot is Gerald. Talking to him is just like talking to ChatGPT directly, he has no special directive. If you are an admin, you can go to `/bots` and experiment with creating additional bots with custom directives that make them take on specialized roles and/or personalities.

### Bots have short-term and long-term memory capability
As users are chatting with bots, bots passively make observations about the user and the conversation and store those as memories in the `thoughts` table. If Marqo is enabled, thoughts are also stored as vectors so that they can be queried using tensor search. An essential part of the bots built-in programming is to act human-like and remember who you are. Bots that are configured to be friendly will often proactively ask you how you're doing today and follow up about previous conversation topics. Active mitigation prevents bots from littering their conversations with “as a language model” disclaimers.

### Conversations feature scrolling context windows
So that you never abruptly run out of tokens while chatting, the conversation transcript that is sent to OpenAI is windowed. That means that if a conversation gets long enough, earlier messages will not be included in the context. If you sense that the conversation is losing vital context, just start a new one. Because bots have memory, you shouldn't have to repeat too much from the previous conversations.

### Automatic titling, summarization and tagging of conversations
A background process automatically adds analysis metadata to conversations. We will eventually add configuration options to this process so that it only runs on demand, or at periodic intervals instead of after every message exchange.
### Ability to make conversations publicly viewable like this
Type `/public` to make a conversation available to non-authenticated visitors.

### Multi-mode chat input
The text input for chatting can be toggled between single line and grow modes, for maximum usability. Just type `/grow` to toggle. In grow mode, cmd+enter submits your message (or hit the send button.)

### Sane prompt management abstraction
All prompts are stored in `config/prompts.yml` and the plan is to eventually make them editable at runtime.

### Dynamic settings system
The user settings page is dynamically configured with entries in the i18n yaml file. This is not done to be cute or clever, but with an eye towards gem-based plugins to the platform being able to dynamically add user settings at runtime without having to have their own user-facing templates.

### Universal internationalization!
A dynamic text helper, backed by GPT itself, is used to generate static text in the user interface. This means that you can instantly internationalize your app by changing the preferred language in user settings. Admins can enter freeform text, while normal users get a dropdown with pre-approved selection options.

## Roadmap
We plan to continue adding features (and outside code contributors! hint, hint) at a rapid pace over the coming months, as we strive to make MagmaChat the world’s best platform for building GPT-backed apps.

Here are some of the cool features we are envisioning:

* Ability to include more than one human and more than one bot in the same conversation.
* Bot to bot communication and information sharing.
* Bot tools that give them the ability to integrate with the outside world by doing web searches, being able to pull up websites, invoke APIs and communicate via traditional methods like email and Slack messages.
* Bot teams for putting bots to work on tasks together.
* Autonomous agent features: reflection, planning, independent operation, and much more…
* Fine-tuning features for further refining bot behavior beyond zero-,one-, and few shot training.
* Speech-to-text and text-to-speech for more natural interaction with bots.
* Swappable embedding and vector database options for bot memory.
* Fine-grained, web-based management of all settings and user preferences for everything described above.
* Easy exporting of conversations to formats suitable for sharing and printing

## Requirements & Setup

* Ruby 3.2.1

* Requires Postgres and Redis to be running

* Run `rails db:setup` to create the database

* Run `bin/dev` to fire up the app

* Long-term memory for bots requires Marqo, an open-source, multi-modal vector search engine that you can download and run locally using Docker. More information at https://www.marqo.ai/

### OpenAI API

Make sure you have `OPENAI_ACCESS_TOKEN` environment variable set. (Developers, use a `.env` file in the root of the project.)

### Google Oauth

Right now the only authentication method supported is Google Oauth. You'll need `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` environment variables set.

### Marqo Vector DB

If you're using Marqo, make sure to set the `MARQO_URL` environment variable, otherwise the `MemoryAnnotator` will not run.

### Admin User

Admin privileges are granted simply with the `admin` boolean attribute on `User`. There is no admin UI at the moment, so if you want to give your user admin rights, do it via the console.

### Configuring Bots

Once you have admin rights, you'll be able to access `/bots` to create additional bots beyond just Gerald, the default GPT Assistant that's created automatically. Note that bots must be published in order to show up in the new chat screen for non-admin users. Draft bots show up to admin users so that they can be tested and refined prior to publication.

Type /debug from any chat input to toggle visibility of hidden messages containing inline instructions to the bots from the platform.

## Contributors

We are actively looking for contributors to the project, and the code is littered with todos that present opportunities for independent research and/or feature enhancement.

We must advise you that by submitting a Pull Request, you disavow any rights or claims to any changes submitted to the MagmaChat project and assign the copyright of those changes to Obie Fernandez & WeAreMagma Group, Inc. Should you be unable or unwilling to transfer those rights (as your employment agreement with your employer may prohibit such action), we advise against submitting a pull request. Instead, kindly open an issue and leave the task to be undertaken by another party. This is a common practice for such projects, rather than an exceptional occurrence. This section is essentially a legalistic expression conveying that "If you submit a PR to us, that code becomes our property". In actuality, this is what most people intend to happen 99.9% of the time, and we hope that it does not deter you from making contributions to the project.
