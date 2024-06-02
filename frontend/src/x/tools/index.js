export function isMobileBrowser() {
  const userAgent = navigator.userAgent || navigator.vendor || window.opera;
  // 检测常见的移动设备的用户代理字符串
  const isMobile = /android|avantgo|blackberry|iemobile|ipad|iphone|ipod|j2me|midp|opera mini|palm|phone|p(ixi|re)\/|plucker|pocket|psp|smartphone|symbian|up\.browser|up\.link|webos|wos/i.test(userAgent);
  return isMobile;
}