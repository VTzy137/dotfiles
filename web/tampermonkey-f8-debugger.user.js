// ==UserScript==
// @name         F8 Debugger Shortcut
// @namespace    http://tampermonkey.net/
// @version      2025-05-13
// @description  Triggers debugger on F8 key press for any site
// @author       You
// @match        *://*/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=tampermonkey.net
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
    'use strict';

    const enableDebuggerKey = 'F8';

    function handleKeyDown(event) {
        // Avoid triggering inside input or textarea fields
        const tag = event.target.tagName.toLowerCase();
        const isEditable = tag === 'input' || tag === 'textarea' || event.target.isContentEditable;

        if (event.key === enableDebuggerKey && !isEditable) {
            console.log(`[Tampermonkey] F8 pressed – entering debugger`);
            debugger;
        }
    }

    window.addEventListener('keydown', handleKeyDown, true);
})();
