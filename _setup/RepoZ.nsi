; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "RepoZ"
; !define PRODUCT_VERSION "0.0"   ; Comes as Cake argument
!define PRODUCT_PUBLISHER "Andreas W�scher"
!define PRODUCT_WEB_SITE "https://github.com/awaescher/RepoZ"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_NAME}"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "res\Setup.ico"
!define MUI_UNICON "res\Setup.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "res\modern-wizard.bmp" 
!define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of ${PRODUCT_NAME} and its command line sidekick 'grr'.\r\n\r\nIn addition to that, it will add ${PRODUCT_NAME} to the Windows Autostart. You can change this at any time after the installation by right-clicking the app icon in the system tray.\r\n\r\nIf you are fine with that, click Next to continue."
!define MUI_FINISHPAGE_RUN "$INSTDIR\${PRODUCT_NAME}.exe"
!define MUI_FINISHPAGE_TEXT "${PRODUCT_NAME} ${PRODUCT_VERSION} has been installed on your computer.\r\n\r\nDon't forget to try the ${PRODUCT_NAME} command line sidekick 'grr'.\r\nRun 'grr --help' for more information.\r\n\r\nPlease note that you might need to restart currently opened command line tools to find grr."
!define MUI_FINISHPAGE_TEXT_LARGE ; extra space for the finishpage-text

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "..\_output\${PRODUCT_NAME} ${PRODUCT_VERSION} Setup.exe"
InstallDir "$PROGRAMFILES64\${PRODUCT_NAME}"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Section "RepoZ"
  SetOutPath "$INSTDIR"
  SetOverwrite on
  
  File /r ..\_output\Assemblies\*.*
  File ..\_ref\PathEd.exe ; Add PathEd.exe to add the RepoZ directory to the system's PATH easily
  File ..\_ref\SendKeys.exe ; Add SendKeys.exe to add the RepoZ directory for grr and grrui
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}.lnk" $INSTDIR\${PRODUCT_NAME}.exe
  
  ; Add the installation folder to the system PATH -> to enable grr.exe
  ExecWait '$INSTDIR\PathEd.exe add "$INSTDIR"' ; put the path in quotes because of possible spaces
  
  ; Write RepoZ executable to Windows AutoStart: HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${PRODUCT_NAME}" '"$INSTDIR\${PRODUCT_NAME}.exe"'
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\${PRODUCT_NAME}.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\${PRODUCT_NAME}.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was removed successfully."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Do you really want to remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd

Section Uninstall

  ; Remove RepoZ from the Windows AutoStart
  DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${PRODUCT_NAME}"
  
  ; Remove the installation folder from the system PATH -> was required for grr.exe
  ExecWait '$INSTDIR\PathEd.exe remove "$INSTDIR"'
  
  Delete "$SMPROGRAMS\${PRODUCT_NAME}.lnk"
    
  RMDir /r "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd