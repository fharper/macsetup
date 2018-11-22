echo "Enter your Prey API key (found in the left corner of the Prey web dashboard)"
read line
HOMEBREW_NO_ENV_FILTERING=1 API_KEY="$line" brew cask install prey