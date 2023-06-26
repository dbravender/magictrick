import 'dart:io';

import 'package:magictrick/magictrick.dart';

class SvgSuit {
  String svg;
  String? translateWhenValuePresent;

  SvgSuit(this.svg, [this.translateWhenValuePresent]);

  @override
  String toString() {
    return svg;
  }
}

Map<Suit, String> suitColors = {
  Suit.clubs: "#82bb37",
  Suit.diamonds: "#1eaec4",
  Suit.hearts: "#bf101e",
  Suit.moons: "#64378c",
  Suit.spades: "#415152",
  Suit.stars: "#fdb612",
  Suit.triangles: "#da602d",
};

Map<Suit, SvgSuit> suits = {
  Suit.clubs: SvgSuit(
      """<g id="layer1" transform="translate(-135.7787,-70.6255575)"> <path style="color:#000000;display:block;overflow:visible;visibility:visible;fill:#cce6a9;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:0.519377;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none" d="m 145.35598,80.807295 c -3.45726,-1.460726 -8.54281,0.281534 -7.33958,4.211928 1.17255,3.830115 6.23635,2.989564 7.98741,0.658054 -0.7305,4.420618 -2.01347,5.10884 -2.78243,6.06841 h 8.16406 c -0.82718,-1.02617 -2.32922,-1.647792 -3.21006,-6.128984 1.76446,2.327556 7.06887,3.134441 8.22449,-0.640296 1.13679,-3.713311 -3.98749,-5.827954 -7.39501,-4.14697 3.2675,-1.940656 4.44093,-8.31417 -1.74769,-8.31417 -6.2497,0 -5.20696,6.498063 -1.90119,8.292028 z" id="rect3667-8-12-1-6"/> </g>""",
      "translate(-10, 0)"),
  Suit.diamonds: SvgSuit(
      """<g id="layer1" transform="translate(-113.2,-97.9)"> <path style="fill:#bcecf3;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0.5;stroke-dasharray:none;stroke-opacity:1" d="m 124.78009,99.605963 c -2.83483,3.392067 -6.02613,6.655057 -9.26834,9.788947 3.39499,3.1339 6.63721,6.39688 9.26834,9.78895 2.73297,-3.4566 5.72057,-6.75186 9.26834,-9.78895 -3.44592,-3.13389 -6.5863,-6.46142 -9.26834,-9.788947 z" id="path2139-9-7"/> </g>""",
      "translate(-10, 0)"),
  Suit.hearts: SvgSuit(
      """<g id="layer1" transform="translate(-91,-76.881918)"> <path  id="path30-0-8-4" d="m 102.41344,96.744843 c -1.06463,-3.7069 -3.948145,-6.47787 -6.311364,-9.42505 -1.238486,-1.4897 -2.410846,-3.41854 -1.888292,-5.40914 0.6033,-2.09777 3.149081,-3.26892 5.223227,-2.57744 1.385429,0.42043 2.508029,1.51375 3.043159,2.82073 0.47765,-0.71902 0.85273,-1.52899 1.592,-2.03889 1.77627,-1.45814 4.76316,-1.23696 6.17035,0.61539 1.03656,1.30205 0.81477,3.1195 0.11864,4.52023 -1.15153,2.42467 -3.25301,4.21788 -4.84391,6.35023 -1.20388,1.53933 -2.28597,3.21464 -2.8461,5.08885 -0.0384,0.0894 -0.19074,0.15827 -0.25775,0.055 z" style="fill:#f3737d;fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-dasharray:none;stroke-opacity:1" /></g>""",
      "translate(-10, 0)"),
  Suit.moons: SvgSuit(
      """<g id="layer1" transform="translate(-68.736459,-198.9)"> <path fill="#0000ff" d="m 79.914084,200.911 c -2.2041,2.87401 -3.83878,7.694 -2.02239,11.11614 1.81638,3.42215 6.72986,4.77953 10.34276,4.5597 -1.83454,2.39211 -4.75485,3.58209 -7.77903,3.16979 -3.02418,-0.4123 -5.7505,-2.37208 -7.26233,-5.2204 -1.51182,-2.84832 -1.60832,-6.20683 -0.25701,-8.94628 1.3513,-2.73947 3.97091,-4.49597 6.978,-4.67895" id="path21600-7" style="fill:#e4d8ef;fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-dasharray:none;stroke-opacity:1"/></g>""",
      "translate(-5, 0)"),
  Suit.spades: SvgSuit(
      """<g id="layer1" transform="translate(-75.2,-137)"> <path  id="path2076-5-3-7" d="m 80.570829,145.34561 c -7.181522,6.67739 -0.141595,11.52086 5.536369,8.33299 -1.072113,3.47825 -1.66169,3.7519 -2.312582,4.66792 h 6.130548 c -0.786947,-0.92501 -1.613381,-1.18967 -2.450684,-4.64814 5.797122,3.03077 11.907009,-2.25463 5.474376,-8.35277 -4.206928,-3.34895 -5.840212,-6.4065 -6.189009,-6.84061 -0.334674,0.36173 -2.306464,3.55375 -6.189018,6.84061 z" style="fill:#99acaf;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0.530851;stroke-linecap:butt;stroke-linejoin:miter;stroke-dasharray:none;stroke-opacity:1"/></g>""",
      "translate(-10, 0)"),
  Suit.stars: SvgSuit(
      """<g id="layer1" transform="translate(-68.75,-239.31908)"> <g id="path40437-9-1-7"   transform="matrix(0.51826821,-0.01361055,0.01361055,0.51826821,83.677183,233.16154)" style="stroke-width:0.964419;stroke-dasharray:none"> <path style="color:#000000;fill:#feeabb;stroke-width:0.964419;stroke-dasharray:none" d="m 1.9174013,39.54639 1.1407855,12.647293 -11.1844112,-6.013682 -11.6757686,4.993181 2.263178,-12.495338 -8.356807,-9.561338 12.583132,-1.708861 6.5109778,-10.902412 5.5136253,11.439203 12.3808129,2.823277 z" id="path583-3" /> <path style="color:#000000;fill:#000000;stroke-width:0.964419;stroke-dasharray:none" d="m -6.7597656,15.5625 -6.8261724,11.431641 -13.193359,1.791015 8.761719,10.025391 -2.373047,13.101562 L -8.1484375,46.675781 3.578125,52.980469 2.3828125,39.720703 12.001953,30.515625 -0.97851563,27.556641 Z m -0.083984,1.884766 5.2460938,10.884765 11.7812498,2.685547 -8.7304686,8.353516 0.019531,0.214843 1.0664063,11.820313 -10.6425781,-5.722656 -11.1093756,4.75 2.152344,-11.888672 -7.951172,-9.095703 11.972656,-1.626953 z" id="path585-7" /> </g></g>""",
      "translate(-10,0)"),
  Suit.triangles: SvgSuit(
    """<g id="layer1" transform="translate(-40.538304,-210.40214)"> <path id="path41583-2" style="fill:#f3d1c1;stroke:#000000;stroke-width:0.5;stroke-dasharray:none"   d="m 61.023168,229.47548 c -0.234521,0.37583 -8.837408,0.23682 -9.280403,0.23493 -0.427144,-0.002 -8.744961,0.0642 -8.945729,-0.31282 -0.208217,-0.39102 4.213614,-7.77183 4.43675,-8.15453 0.215151,-0.36901 4.316881,-7.60546 4.743777,-7.59082 0.442739,0.0152 4.623795,7.53501 4.843655,7.9196 0.211992,0.37083 4.428079,7.54126 4.20195,7.90364"/></g>""",
    "translate(-10, 0)",
  ),
};

const Map<int, String> numerals = {
  0: """<g
     id="layer1"
     transform="translate(-99.03686,-16.89077)">
    <g
       aria-label="0"
       id="text25329"
       style="font-size:20.9172px;line-height:1.25;fill:#fffafa;stroke:#000000;stroke-width:0.5"
       transform="translate(13.592016,0.86757546)">
      <path
         d="m 93.240897,27.235276 q 0,-4.269233 1.532022,-5.974884 1.542235,-1.70565 4.687985,-1.70565 1.511596,0 2.481876,0.377898 0.97028,0.367685 1.58309,0.970281 0.61281,0.592381 0.96006,1.256257 0.35748,0.653663 0.57196,1.532022 0.41875,1.67501 0.41875,3.493009 0,4.075177 -1.37882,5.96467 -1.37882,1.889493 -4.749264,1.889493 -1.889493,0 -3.053829,-0.602595 -1.164337,-0.602595 -1.90992,-1.766931 -0.541315,-0.827292 -0.847719,-2.257179 -0.296191,-1.4401 -0.296191,-3.176391 z m 4.126245,0.01021 q 0,2.859773 0.50046,3.911761 0.510674,1.041775 1.470741,1.041775 0.633235,0 1.092837,-0.43918 0.46982,-0.449393 0.68431,-1.40946 0.22469,-0.960066 0.22469,-2.992548 0,-2.982335 -0.51067,-4.003683 -0.50046,-1.031561 -1.511594,-1.031561 -1.031561,0 -1.491168,1.051988 -0.459606,1.041775 -0.459606,3.870908 z"
         id="path25647" />
    </g>
  </g>
""",
  1: """<g
     id="layer1"
     transform="translate(-103.45981,-41.312457)">
    <g
       aria-label="1"
       id="text25251"
       style="font-size:20.9172px;line-height:1.25;fill:#fffafa;stroke:#000000;stroke-width:0.5"
       transform="translate(17.640701,3.18111)">
      <path
         d="m 103.64843,41.381345 v 15.228293 h -4.207955 v -9.978566 q -1.021347,0.776224 -1.981414,1.256257 -0.949853,0.480034 -2.389954,0.919213 v -3.411301 q 2.124403,-0.684303 3.298953,-1.64437 1.17455,-0.960067 1.83843,-2.369526 z"
         id="path25812" />
    </g>
  </g>""",
  2: """<g
     id="layer1"
     transform="translate(-85.837656,-65.2)">
    <g
       aria-label="2"
       id="text25255"
       style="font-size:20.9172px;line-height:1.25;fill:#fffafa;stroke:#000000;stroke-width:0.5">
      <path
         d="M 105.59921,84.381599 H 93.118338 q 0.214483,-1.848639 1.297112,-3.472582 1.092842,-1.634156 4.085391,-3.85048 1.828209,-1.358393 2.338889,-2.063123 0.51067,-0.704729 0.51067,-1.337965 0,-0.684303 -0.51067,-1.164336 -0.50046,-0.490247 -1.266474,-0.490247 -0.796652,0 -1.307325,0.50046 -0.500461,0.50046 -0.67409,1.766932 l -4.167098,-0.337045 q 0.245123,-1.756718 0.898786,-2.737212 0.653662,-0.990707 1.838425,-1.511594 1.194977,-0.531101 3.298953,-0.531101 2.195893,0 3.411303,0.50046 1.22562,0.500461 1.92013,1.542235 0.70473,1.031561 0.70473,2.318459 0,1.368606 -0.80686,2.61465 -0.79665,1.246044 -2.91084,2.737212 -1.25626,0.868146 -1.68523,1.215404 -0.41875,0.347258 -0.990704,0.908999 h 6.495774 z"
         id="path26001" />
    </g>
  </g>""",
  3: """<g
     id="layer1"
     transform="translate(-85.852907,-93)">
    <g
       aria-label="3"
       id="text25259"
       style="font-size:20.9172px;line-height:1.25;fill:#fffafa;stroke:#000000;stroke-width:0.5">
      <path
         d="m 97.331403,101.38344 -3.932188,-0.70473 q 0.490247,-1.879276 1.879279,-2.880196 1.399247,-1.000921 3.952616,-1.000921 2.93127,0 4.23859,1.092842 1.30733,1.092842 1.30733,2.747425 0,0.97028 -0.5311,1.75672 -0.5311,0.78644 -1.60352,1.37882 0.86815,0.21448 1.32775,0.50046 0.74559,0.4596 1.15413,1.2154 0.41875,0.74559 0.41875,1.78736 0,1.30732 -0.6843,2.51252 -0.68431,1.19497 -1.97121,1.84863 -1.28689,0.64345 -3.380656,0.64345 -2.042696,0 -3.227459,-0.48003 -1.17455,-0.48003 -1.94056,-1.39925 -0.755798,-0.92942 -1.164337,-2.32867 l 4.156885,-0.55153 q 0.245124,1.25626 0.755798,1.74651 0.520887,0.48003 1.317538,0.48003 0.837501,0 1.389031,-0.61281 0.56174,-0.61281 0.56174,-1.63415 0,-1.04178 -0.54131,-1.61373 -0.5311,-0.57196 -1.450315,-0.57196 -0.490247,0 -1.348179,0.24513 l 0.214483,-2.97213 q 0.347258,0.0511 0.541314,0.0511 0.817079,0 1.358397,-0.52089 0.55152,-0.52088 0.55152,-1.23583 0,-0.6843 -0.40854,-1.092838 -0.408535,-0.40854 -1.123478,-0.40854 -0.73537,0 -1.194977,0.449393 -0.459606,0.439175 -0.623022,1.552445 z"
         id="path26190" />
    </g>
  </g>""",
  4: """<g
     id="layer1"
     transform="translate(-85.567042,-121.0)">
    <g
       aria-label="4"
       id="text25263"
       style="font-size:20.9172px;line-height:1.25;fill:#fffafa;stroke:#000000;stroke-width:0.5">
      <path
         d="m 100.39544,137.12703 h -7.578397 v -3.42152 l 7.578397,-9.00828 h 3.62579 v 9.20234 h 1.87928 v 3.22746 h -1.87928 v 2.79849 h -3.62579 z m 0,-3.22746 v -4.70841 l -4.00368,4.70841 z"
         id="path26379" />
    </g>
  </g>""",
  5: """<g
     id="layer1"
     transform="translate(-85.810305,-148.51919)">
    <g
       aria-label="5"
       id="text25267"
       style="font-size:20.9172px;line-height:1.25;fill:#fffafa;stroke:#000000;stroke-width:0.5">
      <path
         d="m 94.992512,152.46918 h 9.876428 v 3.31938 h -6.689824 l -0.357471,2.24697 q 0.694516,-0.32683 1.368606,-0.49025 0.684303,-0.16342 1.348179,-0.16342 2.24696,0 3.64621,1.3584 1.39925,1.35839 1.39925,3.42151 0,1.45031 -0.72516,2.78828 -0.71494,1.33797 -2.0427,2.0427 -1.31753,0.70473 -3.380656,0.70473 -1.480954,0 -2.543156,-0.27577 -1.051988,-0.28598 -1.797571,-0.8375 -0.735371,-0.56174 -1.194977,-1.26647 -0.459607,-0.70473 -0.766011,-1.75672 l 4.207952,-0.45961 q 0.153203,1.01114 0.714944,1.54224 0.561741,0.52088 1.337965,0.52088 0.86815,0 1.42989,-0.65366 0.57195,-0.66388 0.57195,-1.9712 0,-1.33797 -0.57195,-1.96099 -0.57196,-0.62302 -1.521811,-0.62302 -0.602595,0 -1.164336,0.29619 -0.418753,0.21448 -0.919213,0.77623 l -3.544077,-0.51068 z"
         id="path26568" />
    </g>
  </g>""",
  6: """<g
     id="layer1"
     transform="translate(-85.53686,-176.3)">
    <g
       aria-label="6"
       id="text25271"
       style="font-size:20.9172px;line-height:1.25;fill:#fffafa;stroke:#000000;stroke-width:0.5">
      <path
         d="m 105.2111,183.73926 -4.13646,0.51067 q -0.16342,-0.86814 -0.55153,-1.22562 -0.3779,-0.35747 -0.939637,-0.35747 -1.011134,0 -1.572875,1.02135 -0.408539,0.73537 -0.602596,3.14575 0.745584,-0.7558 1.532022,-1.11327 0.786438,-0.36768 1.817996,-0.36768 2.00184,0 3.38066,1.42988 1.38904,1.42989 1.38904,3.62579 0,1.48095 -0.70473,2.70657 -0.69452,1.22562 -1.94056,1.85885 -1.23583,0.62302 -3.104901,0.62302 -2.246965,0 -3.605357,-0.76601 -1.358393,-0.76601 -2.175471,-2.44102 -0.806864,-1.68522 -0.806864,-4.45307 0,-4.05475 1.70565,-5.93403 1.705651,-1.8895 4.72884,-1.8895 1.787363,0 2.818923,0.41876 1.04177,0.40853 1.72607,1.20519 0.68431,0.79665 1.04178,2.00184 z m -7.660109,6.6694 q 0,1.2154 0.612809,1.90992 0.612808,0.6843 1.501381,0.6843 0.817079,0 1.368609,-0.62302 0.55152,-0.62302 0.55152,-1.85885 0,-1.26648 -0.57195,-1.93035 -0.57195,-0.66388 -1.419674,-0.66388 -0.868145,0 -1.460527,0.64345 -0.582168,0.64345 -0.582168,1.83843 z"
         id="path26757" />
    </g>
  </g>""",
  7: """ <g
     id="layer1"
     transform="translate(-85.03686,-203.89077)">
    <g
       aria-label="7"
       id="text25275"
       style="font-size:20.9172px;line-height:1.25;fill:#fffafa;stroke:#000000;stroke-width:0.5">
      <path
         d="m 93.286856,208.14077 h 12.143824 v 2.8087 q -1.58309,1.42989 -2.64529,3.09469 -1.2869,2.02226 -2.03248,4.50414 -0.59238,1.93035 -0.796654,4.56542 h -4.146671 q 0.490246,-3.66663 1.542235,-6.14851 1.051988,-2.48187 3.32959,-5.31101 h -7.394554 z"
         id="path26946" />
    </g>
  </g>""",
};

String card({
  required String borderColor,
  required double borderWidth,
  required Suit suit,
  int? value,
}) {
  String color = suitColors[suit]!;
  return """
<svg width="23" height="23" xmlns="http://www.w3.org/2000/svg">
  <g id="card" mask="url(#a)">
    <rect x="1" y="1" width="21" height="21" stroke="none" stroke-linejoin="round" fill="$color" rx="2" ry="2"/>
     <g transform="${value != null ? suits[suit]!.translateWhenValuePresent : ""}">
     ${suits[suit]}
     </g>
     ${value != null ? numerals[value] : ""}
     <rect x="1" y="1" width="21" height="21" stroke-width="$borderWidth" stroke="$borderColor" stroke-linejoin="round" fill="none" rx="2" ry="2"/>
  </g>
  <mask id="a">
    <rect x="1" y="1" width="21" height="21" stroke="#fff" stroke-linejoin="round" fill="#fff" rx="2" ry="2"/>
  </mask>
</svg>
""";
}

void main() {
  String i =
      """<html><body style="background-color:black"><table cellpadding="0" cellspacing="0">""";
  for (var suit in Suit.values) {
    i += "<tr>";
    for (var value in [null, 0, 1, 2, 3, 4, 5, 6, 7]) {
      String filename = '$suit$value.svg';
      i += """<td><img src="$filename" width="75px" height="75px"/></td>""";
      File("planning/cards/$filename").writeAsStringSync(card(
        borderColor: "white",
        borderWidth: 1,
        suit: suit,
        value: value,
      ));
    }
    i += '</tr>';
  }
  i += "</table>";
  File('planning/cards/index.html').writeAsStringSync(i);
}
