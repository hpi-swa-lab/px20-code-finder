#!/bin/bash

CODEREUSEDIR=$(pwd)
cd ..
WORKINGDIR=$(pwd)
MX_PATH=""
MX_COMMAND=mx
GU_COMMAND=""
GRAAL_PATH="$WORKINGDIR/graal"

GRAALPYTHON_PATH="$WORKINGDIR/graalpython"
PYTHON_LANGUAGE_FILE="${GRAALPYTHON_PATH}/graalpython/com.oracle.graal.python/src/com/oracle/graal/python/PythonLanguage.java"

GRAALJS_PATH="$WORKINGDIR/graaljs"
JS_LANGUAGE_FILE="$GRAALJS_PATH/graal-js/src/com.oracle.truffle.js/src/com/oracle/truffle/js/runtime/AbstractJavaScriptLanguage.java"
JS_MX_FILE="$GRAALJS_PATH/graal-js/mx.graal-js/mx_graal_js.py"

FASTR_PATH="$WORKINGDIR/fastr"
R_LANGUAGE_FILE="$FASTR_PATH/com.oracle.truffle.r.runtime/src/com/oracle/truffle/r/runtime/context/TruffleRLanguage.java"
R_MX_SUITE_FILE="$FASTR_PATH/mx.fastr/suite.py"

JS_INSTALLABLE=""
PYTHON_INSTALLABLE=""
R_INSTALLABLE=""

LOG_FILE="$CODEREUSEDIR/setup.log"
touch $LOG_FILE

# Use (and install) gnu-sed on macOS, since the default sed behaves differently than the Linux sed.
if [ "$(uname)" = "Linux" ]
then
  SED_COMMAND="sed"
elif [ "$(uname)" = "Darwin" ]
then
  if [ -z "$(command -v gsed)" ]
  then
    echo "Installing gnu-sed" | tee -a $LOG_FILE
    brew install gnu-sed  >> $LOG_FILE 2>&1
  fi
  SED_COMMAND="gsed"
else
  echo "Unsupported platform $(uname)! You will need to compile the languages manually."
  exit 1
fi

usage() {
  echo "Required:"
  echo "- [ -g | --gu GU_COMMAND ]:"
  echo
  echo "        Path to GraalVM updater binary gu"
  echo
  echo "Optional:"
  echo "- [ -m | --mx MX_PATH ]:"
  echo
  echo "        Path to mx root dir. If none is given, mx needs to be in path"
  echo
  echo "Others:"
  echo "- [ -h | --help ]"
  echo
  echo "        Print this message"
  exit 1
}

# Search and replace logic of isThreadAccessAllowed in PythonLanguage.java to allow multi threading for python
patch_graalpython() {
  $SED_COMMAND -i '544 s/if (singleThreaded) {//' "$PYTHON_LANGUAGE_FILE"
  $SED_COMMAND -i '545 s/return super.isThreadAccessAllowed(thread, singleThreaded);/        return true;/' "$PYTHON_LANGUAGE_FILE"
  $SED_COMMAND -i '546 s/}//' "$PYTHON_LANGUAGE_FILE"
  $SED_COMMAND -i '547 s/return isWithThread;//' "$PYTHON_LANGUAGE_FILE"
}

add_thread_access_allowed() {
  LANGUAGE_FILE=$1
  OFFSET="$2"
  if [ -z "$(grep 'protected boolean isThreadAccessAllowed(Thread thread, boolean singleThreaded)' $LANGUAGE_FILE)" ]; then
    $SED_COMMAND -i "$((OFFSET++))"' a \\n' "$LANGUAGE_FILE"
    $SED_COMMAND -i "$((OFFSET++))"' a \\    @Override' "$LANGUAGE_FILE"
    $SED_COMMAND -i "$((OFFSET++))"' a \\    protected boolean isThreadAccessAllowed(Thread thread, boolean singleThreaded) {' "$LANGUAGE_FILE"
    $SED_COMMAND -i "$((OFFSET++))"' a \\        return true;' "$LANGUAGE_FILE"
    $SED_COMMAND -i "$((OFFSET++))"' a \\    }' "$LANGUAGE_FILE"
  fi
}

patch_graaljs() {
  add_thread_access_allowed $JS_LANGUAGE_FILE "64"
  $SED_COMMAND -i '309 s/False/True/' $JS_MX_FILE
}

patch_fastr() {
  add_thread_access_allowed $R_LANGUAGE_FILE "238"
  $SED_COMMAND -i '57 s/9a12bd6038c2bb60409b29beafd2db10a06bad8e/8a26107bf9f82a2dcfa597f15549a412be75e0ee/' $R_MX_SUITE_FILE
}

patch_and_build() {
  # Check if graal repo is present. If not, clone and then checkout the correct branch
  if [ ! -d $GRAAL_PATH ]
  then
    echo "Cloning graal into $GRAAL_PATH" | tee -a $LOG_FILE
    git clone https://github.com/oracle/graal.git $GRAAL_PATH >> $LOG_FILE 2>&1
  fi
  cd $GRAAL_PATH
  git checkout vm-19.3.0 >> $LOG_FILE 2>&1
  cd "$WORKINGDIR"

  # Check if graalpython repo is present. If not, clone and checkout the correct branch
  if [ ! -d $GRAALPYTHON_PATH ]
  then
    echo "Cloning graalpython into $GRAALPYTHON_PATH" | tee -a $LOG_FILE
    git clone https://github.com/graalvm/graalpython.git $GRAALPYTHON_PATH >> $LOG_FILE 2>&1
  fi
  cd $GRAALPYTHON_PATH
  git checkout vm-19.3.0 >> $LOG_FILE 2>&1
  patch_graalpython
  # Build Graalpython using mx
  echo "Building graalpython" | tee -a $LOG_FILE
  $MX_COMMAND --dy /vm build >> $LOG_FILE 2>&1
  INSTALLABLE_NAME=$($MX_COMMAND --dy /vm graalvm-show | grep "INSTALLABLE" | grep "PYTHON"| cut -c 3-)
  PYTHON_INSTALLABLE=$($MX_COMMAND --dy /vm paths $INSTALLABLE_NAME)
  cd "$WORKINGDIR"

  # Check if graaljs repo is present. If not, clone and checkout the correct branch
  if [ ! -d $GRAALJS_PATH ]
  then
    echo "Cloning graaljs into $GRAALJS_PATH" | tee -a $LOG_FILE
    git clone https://github.com/graalvm/graaljs.git $GRAALJS_PATH >> $LOG_FILE 2>&1
  fi
  cd $GRAALJS_PATH/graal-js
  git checkout vm-19.3.0 >> $LOG_FILE 2>&1
  patch_graaljs
  # Build GraalJS using mx
  echo "Building graaljs" | tee -a $LOG_FILE
  $MX_COMMAND --dy /vm build >> $LOG_FILE 2>&1
  INSTALLABLE_NAME=$($MX_COMMAND --dy /vm graalvm-show | grep "INSTALLABLE" | grep "JS"| cut -c 3-)
  JS_INSTALLABLE=$($MX_COMMAND --dy /vm paths $INSTALLABLE_NAME)
  cd "$WORKINGDIR"

  # Check if fastr repo is present. If not, clone and checkout the correct branch
  if [ ! -d $FASTR_PATH ]
  then
    echo "Cloning fastr into $FASTR_PATH" | tee -a $LOG_FILE
    git clone https://github.com/oracle/fastr.git $FASTR_PATH >> $LOG_FILE 2>&1
  fi
  cd $FASTR_PATH
  git checkout vm-19.3.0 >> $LOG_FILE 2>&1
  patch_fastr
  # Build FastR using mx
  echo "Building fastr" | tee -a $LOG_FILE
  env FASTR_RELEASE=true $MX_COMMAND --dy /vm build >> $LOG_FILE 2>&1
  INSTALLABLE_NAME=$(env FASTR_RELEASE=true $MX_COMMAND --dy /vm graalvm-show | grep "INSTALLABLE" | grep "R_"| cut -c 3-)
  R_INSTALLABLE=$(env FASTR_RELEASE=true $MX_COMMAND --dy /vm paths $INSTALLABLE_NAME)
  cd "$WORKINGDIR"
}

install() {
  # Validate if all required variables are set so far and install all possible language patches
  echo "Installing Graalpython" | tee -a $LOG_FILE
  if [ -z $PYTHON_INSTALLABLE ] || [ ! -f $PYTHON_INSTALLABLE ]
  then
    echo "ERROR: No Graalpython installable! Install of Graalpython failed." | tee -a $LOG_FILE
  else
    # Check if python already installed. If true, remove currently installed python
    if [ ! -z "$($GU_COMMAND list | grep 'python')" ]
    then
      $GU_COMMAND remove python >> $LOG_FILE 2>&1
    fi
    $GU_COMMAND install -L "$PYTHON_INSTALLABLE" >> $LOG_FILE 2>&1
  fi

  echo "Installing GraalJS" | tee -a $LOG_FILE
  if [ -z $JS_INSTALLABLE ] || [ ! -f $JS_INSTALLABLE ]
  then
    echo "ERROR: No GraalJS installable! Install of GraalJS failed." | tee -a $LOG_FILE
  else
    $GU_COMMAND install -f -L "$JS_INSTALLABLE" >> $LOG_FILE 2>&1
  fi

  echo "Installing FastR" | tee -a $LOG_FILE
  if [ -z $R_INSTALLABLE ] || [ ! -f $R_INSTALLABLE ]
  then
    echo "ERROR: No FastR installable! Install of FastR failed." | tee -a $LOG_FILE
  else
    # Check if R already installed. If true, remove currently installed python
    if [ ! -z "$($GU_COMMAND list | grep 'FastR')" ]
    then
      $GU_COMMAND remove r >> $LOG_FILE 2>&1
    fi
    R_OUTPUT=$($GU_COMMAND install -L "$R_INSTALLABLE")
    # Run the configure_fastr script
    echo "Configuring FastR" | tee -a $LOG_FILE
    echo $R_OUTPUT >> $LOG_FILE
    # Use xargs to trim whitespace
    CONFIGURE_PATH=$(echo $R_OUTPUT | grep "configure_fastr" | xargs)
    $CONFIGURE_PATH >> $LOG_FILE 2>&1
  fi
}

# Get command line parameter
while [ "$1" != "" ]; do
  case $1 in
    -m | --mx )         shift
                        MX_PATH="$1"
                        ;;
    -g | --graal  )     shift
                        GU_COMMAND="$1"
                        ;;
    * )                 usage
  esac
  shift
done

# Validate input
if [ -z "$GU_COMMAND" ]
then
  echo "Error: gu path not set" | tee -a $LOG_FILE
  usage
fi

# If mx path is set, use mx command from this path
if [ ! -z "$MX_PATH" ]
then
  MX_COMMAND="$MX_PATH"/mx
fi

# Set the gu path to an absolute path
cd $CODEREUSEDIR
GU_COMMAND="$(cd "$(dirname "$GU_COMMAND")"; pwd)/$(basename "$GU_COMMAND")"
cd $WORKINGDIR

echo "Building languages with graal updater $GU_COMMAND with mx tool $MX_COMMAND" | tee -a $LOG_FILE
echo "Logging to $LOG_FILE"
patch_and_build
install
