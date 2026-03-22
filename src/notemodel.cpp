#include "notemodel.h"

#include <KConfig>
#include <KConfigGroup>

NoteModel::NoteModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int NoteModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_notes.size();
}

QVariant NoteModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_notes.size()) {
        return {};
    }

    const Note &note = m_notes.at(index.row());
    switch (role) {
    case TitleRole:
        return note.title;
    case ContentRole:
        return note.content;
    }
    return {};
}

bool NoteModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_notes.size()) {
        return false;
    }

    Note &note = m_notes[index.row()];
    switch (role) {
    case TitleRole:
        note.title = value.toString();
        break;
    case ContentRole:
        note.content = value.toString();
        break;
    default:
        return false;
    }
    Q_EMIT dataChanged(index, index, {role});
    return true;
}

QHash<int, QByteArray> NoteModel::roleNames() const
{
    return {
        {TitleRole, "title"},
        {ContentRole, "content"},
    };
}

int NoteModel::count() const
{
    return m_notes.size();
}

int NoteModel::currentIndex() const
{
    return m_currentIndex;
}

void NoteModel::setCurrentIndex(int index)
{
    if (m_currentIndex == index) {
        return;
    }
    m_currentIndex = index;
    Q_EMIT currentIndexChanged();
}

QString NoteModel::nextDefaultTitle() const
{
    int n = m_noteCounter + 1;
    // Find a title that doesn't already exist
    while (true) {
        QString candidate = QStringLiteral("Note %1").arg(n);
        bool found = false;
        for (const auto &note : m_notes) {
            if (note.title == candidate) {
                found = true;
                break;
            }
        }
        if (!found) {
            return candidate;
        }
        ++n;
    }
}

void NoteModel::addNote()
{
    ++m_noteCounter;
    Note note;
    note.title = nextDefaultTitle();
    note.content = QString();

    beginInsertRows(QModelIndex(), m_notes.size(), m_notes.size());
    m_notes.append(note);
    endInsertRows();
    Q_EMIT countChanged();

    setCurrentIndex(m_notes.size() - 1);
}

void NoteModel::removeNote(int index)
{
    if (index < 0 || index >= m_notes.size()) {
        return;
    }

    beginRemoveRows(QModelIndex(), index, index);
    m_notes.remove(index);
    endRemoveRows();
    Q_EMIT countChanged();

    if (m_notes.isEmpty()) {
        setCurrentIndex(-1);
    } else {
        int newIndex = qMin(index, m_notes.size() - 1);
        setCurrentIndex(newIndex);
    }
}

void NoteModel::setTitle(int index, const QString &title)
{
    setData(createIndex(index, 0), title, TitleRole);
}

void NoteModel::setContent(int index, const QString &content)
{
    setData(createIndex(index, 0), content, ContentRole);
}

QString NoteModel::getTitle(int index) const
{
    if (index < 0 || index >= m_notes.size()) {
        return {};
    }
    return m_notes.at(index).title;
}

QString NoteModel::getContent(int index) const
{
    if (index < 0 || index >= m_notes.size()) {
        return {};
    }
    return m_notes.at(index).content;
}

void NoteModel::loadFromConfig()
{
    KConfig config(QStringLiteral("jotpadrc"));
    KConfigGroup general = config.group(QStringLiteral("General"));

    int count = general.readEntry("count", 0);
    int savedCurrent = general.readEntry("currentIndex", 0);
    int maxCounter = 0;

    beginResetModel();
    m_notes.clear();

    for (int i = 0; i < count; ++i) {
        KConfigGroup noteGroup = config.group(QStringLiteral("Note_%1").arg(i));
        Note note;
        note.title = noteGroup.readEntry("title", QStringLiteral("Note %1").arg(i + 1));
        note.content = noteGroup.readEntry("content", QString());
        m_notes.append(note);

        // Track highest note number from default titles
        if (note.title.startsWith(QLatin1String("Note "))) {
            bool ok = false;
            int n = note.title.mid(5).toInt(&ok);
            if (ok && n > maxCounter) {
                maxCounter = n;
            }
        }
    }

    m_noteCounter = maxCounter;
    endResetModel();
    Q_EMIT countChanged();

    if (!m_notes.isEmpty()) {
        m_currentIndex = qBound(0, savedCurrent, m_notes.size() - 1);
        Q_EMIT currentIndexChanged();
    } else {
        m_currentIndex = -1;
    }
}

void NoteModel::saveToConfig() const
{
    KConfig config(QStringLiteral("jotpadrc"));
    KConfigGroup general = config.group(QStringLiteral("General"));
    general.writeEntry("count", m_notes.size());
    general.writeEntry("currentIndex", m_currentIndex);

    // Remove old note groups first
    const QStringList groups = config.groupList();
    for (const QString &grp : groups) {
        if (grp.startsWith(QLatin1String("Note_"))) {
            config.deleteGroup(grp);
        }
    }

    for (int i = 0; i < m_notes.size(); ++i) {
        KConfigGroup noteGroup = config.group(QStringLiteral("Note_%1").arg(i));
        noteGroup.writeEntry("title", m_notes.at(i).title);
        noteGroup.writeEntry("content", m_notes.at(i).content);
    }

    config.sync();
}
