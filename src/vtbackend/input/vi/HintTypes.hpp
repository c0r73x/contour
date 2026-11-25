// SPDX-License-Identifier: Apache-2.0
#pragma once

#include <cstdint>
#include <string>
#include <string_view>

namespace vtbackend
{

/// Defines the action to perform when a hint is selected.
enum class HintAction : uint8_t
{
    Copy,         ///< Copy matched text to clipboard.
    Open,         ///< Open matched text (e.g. URL in browser).
    Paste,        ///< Paste matched text into the terminal input.
    CopyAndPaste, ///< Copy to clipboard and paste into terminal.
    Select,       ///< Pre-select the match range in visual mode.
};

/// How much of the terminal a hint activation scans.
enum class HintScope : uint8_t
{
    Visible = 0,    ///< The visible page only.
    Scrollback = 1, ///< The visible page plus scrollback history, up to a configured limit.
};

/// The label alphabet hint mode uses when none is configured.
inline constexpr std::string_view DefaultHintAlphabet = "abcdefghijklmnopqrstuvwxyz";

/// @p alphabet as hint mode uses it: lowercased, printable ASCII other than space, each character once.
/// Fewer than two characters left cannot build labels, and select @ref DefaultHintAlphabet instead.
[[nodiscard]] std::string normalizeHintAlphabet(std::string_view alphabet);

} // namespace vtbackend
