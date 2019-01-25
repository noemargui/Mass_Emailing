require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'mime'
include MIME

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'Gmail API Ruby Quickstart'.freeze
CREDENTIALS_PATH = 'credentials.json'.freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::GmailV1::AUTH_SCOPE # changer read only en SCOPE

# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

# Initialize the API
service = Google::Apis::GmailV1::GmailService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# Création du contenu du message
msg = Mail.new #msg est une instance de la classe « Mail ». On va définir ses variables d’instance
msg.date = Time.now
msg.subject = 'Robot-rement il est en bombe'
msg.body = Text.new('Signé Noé. AKA futur Hackeur en devenir..', 'plain', 'charset' => 'us-ascii')
msg.from = {'noemargeek@gmail.com' => 'Robot'}
msg.to   = {[
    'noe.marguillard@sfr.fr', 'jeanne.pelisson@essec.edu'] => nil,
}

# Création de la requête, insertion du contenu dans la propriété `raw`
#(https://developers.google.com/gmail/api/v1/reference/users/messages/send)
message = Google::Apis::GmailV1::Message.new(raw: msg.to_s)
service.send_user_message('me', message)