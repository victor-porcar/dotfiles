export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

alias mci='mvn clean install'
alias mcis='mvn clean install -DskipTests'
alias mdt='mvn dependency:tree'
alias mdu='mvn versions:display-dependency-updates'
alias mw='./mvnw'
alias gw='./gradlew'
