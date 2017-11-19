#include "scriptlauncher.h"

ScriptLauncher::ScriptLauncher(QObject *parent) :
    QObject(parent),
    m_process(new QProcess(this))
{
}

void ScriptLauncher::launchScript()
{
    m_process->start("dconf reset -f /apps/harbour-matrix/settings/");
}
