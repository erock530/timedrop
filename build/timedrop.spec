# This is the spec file for timedrop

%define _topdir		/home/erock530/go/src/github.com/erock530/timedrop
%define name		timedrop
%define release		el7
%define version 1.1.2
%define debug_package %{nil}

BuildRoot:	%{buildroot}
Summary:	Microservice for time. nginx /time endpoint
License:	GPL
Name:		%{name}
Version:	%{version}
Release:	%{release}
Source:		%{name}.tar.gz
Prefix:		/data/usr
Group:		Development/Tools
Requires:	nginx
URL:		https://github.com/erock530/timedrop

%description
Package provides a '/time endpoint in nginx to json time-providing microservice.

%prep
%setup -q

%build
echo "   timedrop"
echo "   Begin Build Phase"
rm -rf %{buildroot}
rm -rf %{_builddir}/%{name}

%pre

%install
#echo "Install section"

install --directory $RPM_BUILD_ROOT/bin/
install --directory $RPM_BUILD_ROOT/etc
install --directory $RPM_BUILD_ROOT/etc/systemd
install --directory $RPM_BUILD_ROOT/etc/systemd/system
install --directory $RPM_BUILD_ROOT/etc/nginx
install --directory $RPM_BUILD_ROOT/etc/nginx/conf.d
install --directory $RPM_BUILD_ROOT/usr/local
install --directory $RPM_BUILD_ROOT/usr/local/share
install --directory $RPM_BUILD_ROOT/usr/local/share/man
install --directory $RPM_BUILD_ROOT/usr/local/share/man/man8


# Copy files
/bin/cp -rf ./bin/timedrop $RPM_BUILD_ROOT/bin/timedrop
/bin/cp -rf ./etc/systemd/system/timedrop.service $RPM_BUILD_ROOT/etc/systemd/system/timedrop.service
/bin/cp -rf ./etc/nginx/conf.d/timedrop.conf $RPM_BUILD_ROOT/etc/nginx/conf.d/timedrop.conf
/bin/cp -rf ./man/timedrop $RPM_BUILD_ROOT/usr/local/share/man/man8/timedrop.8

%post

echo "  Begin Post Install Phase"
mandb -q
systemctl daemon-reload
nginx -s reload
systemctl enable --now timedrop
echo "  Done Post Install Phase"

%files
%defattr(-,root,root) 
%attr(755,root,root) /bin/timedrop
%attr(644,root,root) /etc/systemd/system/timedrop.service
%attr(644,root,root) /etc/nginx/conf.d/timedrop.conf
%attr(644,root,root) /usr/local/share/man/man8/timedrop.8

%preun
#if [ $1 == "0" ]; then # rpm is getting removed. if $1 = 1 then it's an upgrade
/usr/bin/systemctl --no-reload stop timedrop
/usr/bin/systemctl --no-reload disable timedrop

#fi

%postun
#if [ $1 == "0" ]; then # rpm is getting removed. if $1 = 1 then it's an upgrade
mandb -q
systemctl daemon-reload
#fi

%Clean
echo "  Cleaning Build Directories"
rm -rf %{buildroot}
rm -rf %{_builddir}/%{name}
