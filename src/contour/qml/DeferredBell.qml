// SPDX-License-Identifier: Apache-2.0
import QtQuick

/// A bell that may be rung before multimedia is ready.
///
/// The player (BellSound.qml) is loaded only once `terminalSessions.multimediaReady` turns true, because
/// QtMultimedia's driver probing costs seconds at startup. A bell rung before then is kept -- the most
/// recent one, not a queue: two bells in a row are one bell to the ear -- and played the moment the
/// player is there. SessionChrome rings one of these for its pane, Main.qml one for the whole window.
Item {
    id: bell

    /// The player component to load. BellSound.qml in production; a test hands in a stand-in, so the
    /// deferral is observable without QtMultimedia.
    property url playerSource: Qt.resolvedUrl("BellSound.qml")

    /// The sound and volume of the bell rung before the player was ready; volume -1 when there is none.
    property string pendingSource: ""
    property real pendingVolume: -1

    /// Whether a bell was ever rung here; the player loads only then.
    property bool wanted: false

    /// Plays @p source at @p volume now, or as soon as the player has loaded.
    /// @param source The sound's URL; empty plays nothing.
    /// @param volume The playback volume (0.0 to 1.0).
    function play(source, volume) {
        // The player (and QtMultimedia with it) loads on the first bell rung, never for a silent window.
        if (String(source) !== "")
            bell.wanted = true;
        if (loader.status === Loader.Ready) {
            loader.item.source = source;
            loader.item.play(volume);
            return;
        }
        bell.pendingSource = source;
        bell.pendingVolume = volume;
    }

    Loader {
        id: loader
        active: terminalSessions.multimediaReady && bell.wanted
        asynchronous: true
        source: bell.playerSource
        onLoaded: {
            if (bell.pendingVolume < 0)
                return;
            item.source = bell.pendingSource;
            item.play(bell.pendingVolume);
            bell.pendingSource = "";
            bell.pendingVolume = -1;
        }
    }
}
