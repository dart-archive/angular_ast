// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import '../schema.dart';

const _EVENT = const NgTypeReference.dartSdk('html', 'Event');
const _BOOLEAN = const NgTypeReference.dartSdk('core', 'bool');
const _NUMBER = const NgTypeReference.dartSdk('core', 'num');
const _STRING = const NgTypeReference.dartSdk('core', 'String');
const _OBJECT = const NgTypeReference.dartSdk('core', 'Map');
const _NO_TYPE = null;

const List<String> _SCHEMA = const [
  "*|%classList,className,id,innerHTML,*beforecopy,*beforecut,*beforepaste,*copy,*cut,*paste,*search,*selectstart,*webkitfullscreenchange,*webkitfullscreenerror,*wheel,outerHTML,#scrollLeft,#scrollTop",
  "^*|accessKey,contentEditable,dir,!draggable,!hidden,innerText,lang,*abort,*autocomplete,*autocompleteerror,*beforecopy,*beforecut,*beforepaste,*blur,*cancel,*canplay,*canplaythrough,*change,*click,*close,*contextmenu,*copy,*cuechange,*cut,*dblclick,*drag,*dragend,*dragenter,*dragleave,*dragover,*dragstart,*drop,*durationchange,*emptied,*ended,*error,*focus,*input,*invalid,*keydown,*keypress,*keyup,*load,*loadeddata,*loadedmetadata,*loadstart,*message,*mousedown,*mouseenter,*mouseleave,*mousemove,*mouseout,*mouseover,*mouseup,*mousewheel,*mozfullscreenchange,*mozfullscreenerror,*mozpointerlockchange,*mozpointerlockerror,*paste,*pause,*play,*playing,*progress,*ratechange,*reset,*resize,*scroll,*search,*seeked,*seeking,*select,*selectstart,*show,*stalled,*submit,*suspend,*timeupdate,*toggle,*volumechange,*waiting,*webglcontextcreationerror,*webglcontextlost,*webglcontextrestored,*webkitfullscreenchange,*webkitfullscreenerror,*wheel,outerText,!spellcheck,%style,#tabIndex,title,!translate",
  "media|!autoplay,!controls,%crossOrigin,#currentTime,!defaultMuted,#defaultPlaybackRate,!disableRemotePlayback,!loop,!muted,*encrypted,#playbackRate,preload,src,#volume",
  "@svg:^*|*abort,*autocomplete,*autocompleteerror,*blur,*cancel,*canplay,*canplaythrough,*change,*click,*close,*contextmenu,*cuechange,*dblclick,*drag,*dragend,*dragenter,*dragleave,*dragover,*dragstart,*drop,*durationchange,*emptied,*ended,*error,*focus,*input,*invalid,*keydown,*keypress,*keyup,*load,*loadeddata,*loadedmetadata,*loadstart,*mousedown,*mouseenter,*mouseleave,*mousemove,*mouseout,*mouseover,*mouseup,*mousewheel,*pause,*play,*playing,*progress,*ratechange,*reset,*resize,*scroll,*seeked,*seeking,*select,*show,*stalled,*submit,*suspend,*timeupdate,*toggle,*volumechange,*waiting,%style,#tabIndex",
  "@svg:graphics^@svg:|",
  "@svg:animation^@svg:|*begin,*end,*repeat",
  "@svg:geometry^@svg:|",
  "@svg:componentTransferFunction^@svg:|",
  "@svg:gradient^@svg:|",
  "@svg:textContent^@svg:graphics|",
  "@svg:textPositioning^@svg:textContent|",
  "a|charset,coords,download,hash,host,hostname,href,hreflang,name,password,pathname,ping,port,protocol,rel,rev,search,shape,target,text,type,username",
  "area|alt,coords,hash,host,hostname,href,!noHref,password,pathname,ping,port,protocol,search,shape,target,username",
  "audio^media|",
  "br|clear",
  "base|href,target",
  "body|aLink,background,bgColor,link,*beforeunload,*blur,*error,*focus,*hashchange,*languagechange,*load,*message,*offline,*online,*pagehide,*pageshow,*popstate,*rejectionhandled,*resize,*scroll,*storage,*unhandledrejection,*unload,text,vLink",
  "button|!autofocus,!disabled,formAction,formEnctype,formMethod,!formNoValidate,formTarget,name,type,value",
  "canvas|#height,#width",
  "content|select",
  "dl|!compact",
  "datalist|",
  "details|!open",
  "dialog|!open,returnValue",
  "dir|!compact",
  "div|align",
  "embed|align,height,name,src,type,width",
  "fieldset|!disabled,name",
  "font|color,face,size",
  "form|acceptCharset,action,autocomplete,encoding,enctype,method,name,!noValidate,target",
  "frame|frameBorder,longDesc,marginHeight,marginWidth,name,!noResize,scrolling,src",
  "frameset|cols,*beforeunload,*blur,*error,*focus,*hashchange,*languagechange,*load,*message,*offline,*online,*pagehide,*pageshow,*popstate,*rejectionhandled,*resize,*scroll,*storage,*unhandledrejection,*unload,rows",
  "hr|align,color,!noShade,size,width",
  "head|",
  "h1,h2,h3,h4,h5,h6|align",
  "html|version",
  "iframe|align,!allowFullscreen,frameBorder,height,longDesc,marginHeight,marginWidth,name,%sandbox,scrolling,src,srcdoc,width",
  "img|align,alt,border,%crossOrigin,#height,#hspace,!isMap,longDesc,lowsrc,name,sizes,src,srcset,useMap,#vspace,#width",
  "input|accept,align,alt,autocapitalize,autocomplete,!autofocus,!checked,!defaultChecked,defaultValue,dirName,!disabled,%files,formAction,formEnctype,formMethod,!formNoValidate,formTarget,#height,!incremental,!indeterminate,max,#maxLength,min,#minLength,!multiple,name,pattern,placeholder,!readOnly,!required,selectionDirection,#selectionEnd,#selectionStart,#size,src,step,type,useMap,value,%valueAsDate,#valueAsNumber,#width",
  "keygen|!autofocus,challenge,!disabled,keytype,name",
  "li|type,#value",
  "label|htmlFor",
  "legend|align",
  "link|as,charset,%crossOrigin,!disabled,href,hreflang,integrity,media,rel,%relList,rev,%sizes,target,type",
  "map|name",
  "marquee|behavior,bgColor,direction,height,#hspace,#loop,#scrollAmount,#scrollDelay,!trueSpeed,#vspace,width",
  "menu|!compact",
  "meta|content,httpEquiv,name,scheme",
  "meter|#high,#low,#max,#min,#optimum,#value",
  "ins,del|cite,dateTime",
  "ol|!compact,!reversed,#start,type",
  "object|align,archive,border,code,codeBase,codeType,data,!declare,height,#hspace,name,standby,type,useMap,#vspace,width",
  "optgroup|!disabled,label",
  "option|!defaultSelected,!disabled,label,!selected,text,value",
  "output|defaultValue,%htmlFor,name,value",
  "p|align",
  "param|name,type,value,valueType",
  "picture|",
  "pre|#width",
  "progress|#max,#value",
  "q,blockquote,cite|",
  "script|!async,charset,%crossOrigin,!defer,event,htmlFor,integrity,src,text,type",
  "select|!autofocus,!disabled,#length,!multiple,name,!required,#selectedIndex,#size,value",
  "shadow|",
  "source|media,sizes,src,srcset,type",
  "span|",
  "style|!disabled,media,type",
  "caption|align",
  "th,td|abbr,align,axis,bgColor,ch,chOff,#colSpan,headers,height,!noWrap,#rowSpan,scope,vAlign,width",
  "col,colgroup|align,ch,chOff,#span,vAlign,width",
  "table|align,bgColor,border,%caption,cellPadding,cellSpacing,frame,rules,summary,%tFoot,%tHead,width",
  "tr|align,bgColor,ch,chOff,vAlign",
  "tfoot,thead,tbody|align,ch,chOff,vAlign",
  "template|",
  "textarea|autocapitalize,!autofocus,#cols,defaultValue,dirName,!disabled,#maxLength,#minLength,name,placeholder,!readOnly,!required,#rows,selectionDirection,#selectionEnd,#selectionStart,value,wrap",
  "title|text",
  "track|!default,kind,label,src,srclang",
  "ul|!compact,type",
  "unknown|",
  "video^media|#height,poster,#width",
  "@svg:a^@svg:graphics|",
  "@svg:animate^@svg:animation|",
  "@svg:animateMotion^@svg:animation|",
  "@svg:animateTransform^@svg:animation|",
  "@svg:circle^@svg:geometry|",
  "@svg:clipPath^@svg:graphics|",
  "@svg:cursor^@svg:|",
  "@svg:defs^@svg:graphics|",
  "@svg:desc^@svg:|",
  "@svg:discard^@svg:|",
  "@svg:ellipse^@svg:geometry|",
  "@svg:feBlend^@svg:|",
  "@svg:feColorMatrix^@svg:|",
  "@svg:feComponentTransfer^@svg:|",
  "@svg:feComposite^@svg:|",
  "@svg:feConvolveMatrix^@svg:|",
  "@svg:feDiffuseLighting^@svg:|",
  "@svg:feDisplacementMap^@svg:|",
  "@svg:feDistantLight^@svg:|",
  "@svg:feDropShadow^@svg:|",
  "@svg:feFlood^@svg:|",
  "@svg:feFuncA^@svg:componentTransferFunction|",
  "@svg:feFuncB^@svg:componentTransferFunction|",
  "@svg:feFuncG^@svg:componentTransferFunction|",
  "@svg:feFuncR^@svg:componentTransferFunction|",
  "@svg:feGaussianBlur^@svg:|",
  "@svg:feImage^@svg:|",
  "@svg:feMerge^@svg:|",
  "@svg:feMergeNode^@svg:|",
  "@svg:feMorphology^@svg:|",
  "@svg:feOffset^@svg:|",
  "@svg:fePointLight^@svg:|",
  "@svg:feSpecularLighting^@svg:|",
  "@svg:feSpotLight^@svg:|",
  "@svg:feTile^@svg:|",
  "@svg:feTurbulence^@svg:|",
  "@svg:filter^@svg:|",
  "@svg:foreignObject^@svg:graphics|",
  "@svg:g^@svg:graphics|",
  "@svg:image^@svg:graphics|",
  "@svg:line^@svg:geometry|",
  "@svg:linearGradient^@svg:gradient|",
  "@svg:mpath^@svg:|",
  "@svg:marker^@svg:|",
  "@svg:mask^@svg:|",
  "@svg:metadata^@svg:|",
  "@svg:path^@svg:geometry|",
  "@svg:pattern^@svg:|",
  "@svg:polygon^@svg:geometry|",
  "@svg:polyline^@svg:geometry|",
  "@svg:radialGradient^@svg:gradient|",
  "@svg:rect^@svg:geometry|",
  "@svg:svg^@svg:graphics|#currentScale,#zoomAndPan",
  "@svg:script^@svg:|type",
  "@svg:set^@svg:animation|",
  "@svg:stop^@svg:|",
  "@svg:style^@svg:|!disabled,media,title,type",
  "@svg:switch^@svg:graphics|",
  "@svg:symbol^@svg:|",
  "@svg:tspan^@svg:textPositioning|",
  "@svg:text^@svg:textPositioning|",
  "@svg:textPath^@svg:textContent|",
  "@svg:title^@svg:|",
  "@svg:use^@svg:graphics|",
  "@svg:view^@svg:|#zoomAndPan"
];

NgTemplateSchema generateHtml5Schema() {
  final Map<String, NgElementDefinition> schema = {};

  for (final encodedString in _SCHEMA) {
    final parts = encodedString.split("|");
    final rawProperties = parts[1].split(",");
    final typeParts = (parts[0] + "^").split("^");
    final typeName = typeParts[0];

    final superType = schema[typeParts[1]];
    final properties =
        new Map<String, NgPropertyDefinition>.from(superType?.properties ?? {});
    final events =
        new Map<String, NgEventDefinition>.from(superType?.events ?? {});

    for (final property in rawProperties) {
      if (property.isEmpty) {
        continue;
      } else if (property.startsWith("*")) {
        events[property.substring(1)] =
            new NgEventDefinition(property.substring(1), _EVENT);
      } else if (property.startsWith("!")) {
        properties[property.substring(1)] =
            new NgPropertyDefinition(property.substring(1), _BOOLEAN);
      } else if (property.startsWith("#")) {
        properties[property.substring(1)] =
            new NgPropertyDefinition(property.substring(1), _NUMBER);
      } else if (property.startsWith("%")) {
        properties[property.substring(1)] =
            new NgPropertyDefinition(property.substring(1), _OBJECT);
      } else {
        properties[property] = new NgPropertyDefinition(property, _STRING);
      }
    }

    typeName.split(",").forEach((tag) => schema[tag] =
        new NgElementDefinition(tag, properties: properties, events: events));
  }
  schema
   ..remove('')
   ..remove('*');
  return new NgTemplateSchema(schema);
}
