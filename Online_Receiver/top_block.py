#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Top Block
# Generated: Wed Nov 28 16:49:17 2018
##################################################

if __name__ == '__main__':
    import ctypes
    import sys
    if sys.platform.startswith('linux'):
        try:
            x11 = ctypes.cdll.LoadLibrary('libX11.so')
            x11.XInitThreads()
        except:
            print "Warning: failed to XInitThreads()"

from gnuradio import eng_notation
from gnuradio import gr
from gnuradio import wxgui
from gnuradio.eng_option import eng_option
from gnuradio.fft import window
from gnuradio.filter import firdes
from gnuradio.wxgui import fftsink2
from gnuradio.wxgui import forms
from grc_gnuradio import wxgui as grc_wxgui
from optparse import OptionParser
import osmosdr
import time
import wx


class top_block(grc_wxgui.top_block_gui):

    def __init__(self):
        grc_wxgui.top_block_gui.__init__(self, title="Top Block")
        _icon_path = "/usr/share/icons/hicolor/32x32/apps/gnuradio-grc.png"
        self.SetIcon(wx.Icon(_icon_path, wx.BITMAP_TYPE_ANY))

        ##################################################
        # Variables
        ##################################################
        self.samp_rate = samp_rate = 1e6
        self.Freq = Freq = 95.8e6
        self.variable_0 = variable_0 = 0
        self.gain = gain = 10
        self.Sampling_rate = Sampling_rate = samp_rate
        self.Frequency = Frequency = Freq

        ##################################################
        # Blocks
        ##################################################
        _gain_sizer = wx.BoxSizer(wx.VERTICAL)
        self._gain_text_box = forms.text_box(
        	parent=self.GetWin(),
        	sizer=_gain_sizer,
        	value=self.gain,
        	callback=self.set_gain,
        	label='gain',
        	converter=forms.float_converter(),
        	proportion=0,
        )
        self._gain_slider = forms.slider(
        	parent=self.GetWin(),
        	sizer=_gain_sizer,
        	value=self.gain,
        	callback=self.set_gain,
        	minimum=0,
        	maximum=50,
        	num_steps=100,
        	style=wx.SL_HORIZONTAL,
        	cast=float,
        	proportion=1,
        )
        self.Add(_gain_sizer)
        _Sampling_rate_sizer = wx.BoxSizer(wx.VERTICAL)
        self._Sampling_rate_text_box = forms.text_box(
        	parent=self.GetWin(),
        	sizer=_Sampling_rate_sizer,
        	value=self.Sampling_rate,
        	callback=self.set_Sampling_rate,
        	label='Sampling_rate',
        	converter=forms.float_converter(),
        	proportion=0,
        )
        self._Sampling_rate_slider = forms.slider(
        	parent=self.GetWin(),
        	sizer=_Sampling_rate_sizer,
        	value=self.Sampling_rate,
        	callback=self.set_Sampling_rate,
        	minimum=5000,
        	maximum=61440000,
        	num_steps=1000,
        	style=wx.SL_HORIZONTAL,
        	cast=float,
        	proportion=1,
        )
        self.Add(_Sampling_rate_sizer)
        _Frequency_sizer = wx.BoxSizer(wx.VERTICAL)
        self._Frequency_text_box = forms.text_box(
        	parent=self.GetWin(),
        	sizer=_Frequency_sizer,
        	value=self.Frequency,
        	callback=self.set_Frequency,
        	label='Frequency',
        	converter=forms.float_converter(),
        	proportion=0,
        )
        self._Frequency_slider = forms.slider(
        	parent=self.GetWin(),
        	sizer=_Frequency_sizer,
        	value=self.Frequency,
        	callback=self.set_Frequency,
        	minimum=8800000,
        	maximum=109000000,
        	num_steps=1000,
        	style=wx.SL_HORIZONTAL,
        	cast=float,
        	proportion=1,
        )
        self.Add(_Frequency_sizer)
        self.wxgui_fftsink2_0 = fftsink2.fft_sink_c(
        	self.GetWin(),
        	baseband_freq=Frequency,
        	y_per_div=10,
        	y_divs=10,
        	ref_level=0,
        	ref_scale=2.0,
        	sample_rate=Sampling_rate,
        	fft_size=1024,
        	fft_rate=15,
        	average=False,
        	avg_alpha=None,
        	title='FFT Plot',
        	peak_hold=False,
        )
        self.Add(self.wxgui_fftsink2_0.win)
        self.rtlsdr_source_0 = osmosdr.source( args="numchan=" + str(1) + " " + '' )
        self.rtlsdr_source_0.set_clock_source('external_1pps', 0)
        self.rtlsdr_source_0.set_sample_rate(Sampling_rate)
        self.rtlsdr_source_0.set_center_freq(Frequency, 0)
        self.rtlsdr_source_0.set_freq_corr(0, 0)
        self.rtlsdr_source_0.set_dc_offset_mode(0, 0)
        self.rtlsdr_source_0.set_iq_balance_mode(2, 0)
        self.rtlsdr_source_0.set_gain_mode(False, 0)
        self.rtlsdr_source_0.set_gain(gain, 0)
        self.rtlsdr_source_0.set_if_gain(0, 0)
        self.rtlsdr_source_0.set_bb_gain(0, 0)
        self.rtlsdr_source_0.set_antenna('', 0)
        self.rtlsdr_source_0.set_bandwidth(0, 0)
          

        ##################################################
        # Connections
        ##################################################
        self.connect((self.rtlsdr_source_0, 0), (self.wxgui_fftsink2_0, 0))    

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.set_Sampling_rate(self.samp_rate)

    def get_Freq(self):
        return self.Freq

    def set_Freq(self, Freq):
        self.Freq = Freq
        self.set_Frequency(self.Freq)

    def get_variable_0(self):
        return self.variable_0

    def set_variable_0(self, variable_0):
        self.variable_0 = variable_0

    def get_gain(self):
        return self.gain

    def set_gain(self, gain):
        self.gain = gain
        self._gain_slider.set_value(self.gain)
        self._gain_text_box.set_value(self.gain)
        self.rtlsdr_source_0.set_gain(self.gain, 0)

    def get_Sampling_rate(self):
        return self.Sampling_rate

    def set_Sampling_rate(self, Sampling_rate):
        self.Sampling_rate = Sampling_rate
        self._Sampling_rate_slider.set_value(self.Sampling_rate)
        self._Sampling_rate_text_box.set_value(self.Sampling_rate)
        self.wxgui_fftsink2_0.set_sample_rate(self.Sampling_rate)
        self.rtlsdr_source_0.set_sample_rate(self.Sampling_rate)

    def get_Frequency(self):
        return self.Frequency

    def set_Frequency(self, Frequency):
        self.Frequency = Frequency
        self._Frequency_slider.set_value(self.Frequency)
        self._Frequency_text_box.set_value(self.Frequency)
        self.wxgui_fftsink2_0.set_baseband_freq(self.Frequency)
        self.rtlsdr_source_0.set_center_freq(self.Frequency, 0)


def main(top_block_cls=top_block, options=None):

    tb = top_block_cls()
    tb.Start(True)
    tb.Wait()


if __name__ == '__main__':
    main()
