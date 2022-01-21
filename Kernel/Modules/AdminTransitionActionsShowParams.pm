# --
# Copyright (C) 2021 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminTransitionActionsShowParams;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Output::HTML::Layout
    Kernel::System::Web::Request
);

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');

    my $ModuleOrig  = $ParamObject->GetParam( Param => 'Module' );
    my ($Module)    = $ModuleOrig =~ s{[^A-Za-z1-2]}{}g;
    my $Class       = sprintf "Kernel::System::ProcessManagement::TransitionAction::%s",
        $Module || 'ThisModuleLikelyDoesntExistInThisInstallation';

    my $ClassExists = $MainObject->Require(
        $Class,
        Silent => 1,
    );

    my @ModuleParams;

    if ( $Module && $Module eq $ModuleOrig && $ClassExists ) {
        my $Object    = $Kernel::OM->Get($Class);
        @ModuleParams = $Object->Params();
    }

    my $JSON = $LayoutObject->JSONEncode(
        Data => { Params => \@ModuleParams },
    );

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}


1;
