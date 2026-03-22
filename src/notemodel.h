#pragma once

#include <QAbstractListModel>
#include <QObject>
#include <QString>
#include <QVector>

struct Note {
    QString title;
    QString content;
};

class NoteModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)

public:
    enum Roles {
        TitleRole = Qt::UserRole + 1,
        ContentRole,
    };

    explicit NoteModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const;
    int currentIndex() const;
    void setCurrentIndex(int index);

    Q_INVOKABLE void addNote();
    Q_INVOKABLE void removeNote(int index);
    Q_INVOKABLE void setTitle(int index, const QString &title);
    Q_INVOKABLE void setContent(int index, const QString &content);
    Q_INVOKABLE QString getTitle(int index) const;
    Q_INVOKABLE QString getContent(int index) const;

    void loadFromConfig();
    void saveToConfig() const;

Q_SIGNALS:
    void countChanged();
    void currentIndexChanged();

private:
    QString nextDefaultTitle() const;

    QVector<Note> m_notes;
    int m_currentIndex = -1;
    int m_noteCounter = 0;
};
