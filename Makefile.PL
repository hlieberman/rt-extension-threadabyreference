use inc::Module::Install;

RTx     'RT-Extension-ThreadByReference';
license 'perl';
repository 'https://github.com/akamai/rt-extension-threadbyreference';

requires_rt '4.0.0';
rt_too_new '4.4.0';

sign;
WriteAll;
