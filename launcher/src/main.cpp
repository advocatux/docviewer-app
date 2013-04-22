#include <QGuiApplication>

#include <QtQml/qqmlengine.h>
#include <QtQml/qqmlcomponent.h>
#include <QtQml/qqmlcontext.h>

#include <QtQuick/qquickitem.h>
#include <QtQuick/qquickview.h>

#include <QStringList>
#include <qdebug.h>

int main(int argc, char *argv[])
{
    QGuiApplication launcher(argc, argv);

        QQmlEngine engine;

        QQmlComponent *component = new QQmlComponent(&engine);

        component->loadUrl(QString("docviewer.qml"));

        QString argument = "";
        if (launcher.arguments().size() >= 2)
            argument = launcher.arguments().at(1);

        /**SEND ARGUMENT**/
        //engine.rootContext()->setContextProperty("fileName", launcher.arguments().at(1));
        engine.rootContext()->setContextProperty("file", QVariant::fromValue(argument));

        /*if ( !component->isReady() ) {
            qFatal(qPrintable(component->errorString()));
            return -1;
        } FIXME */

        QObject *topLevel = component->create();
        QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
        QQuickView* qxView = 0;

        if (!window) {

            QQuickItem *contentItem = qobject_cast<QQuickItem *>(topLevel);

            if (contentItem) {

                qxView = new QQuickView(&engine, NULL);
                window = qxView;
                window->setFlags(Qt::Window | Qt::WindowSystemMenuHint | Qt::WindowTitleHint | Qt::WindowMinMaxButtonsHint | Qt::WindowCloseButtonHint);

                qxView->setResizeMode(QQuickView::SizeRootObjectToView);
                qxView->setContent(QString("docviewer.qml"), component, contentItem);
            }
        }

        if (window)
            window->show();

    return launcher.exec();
}
