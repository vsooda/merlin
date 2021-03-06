#!/bin/bash

if test "$#" -ne 2; then
    echo "Usage: ./scripts/prepare_config_files.sh conf/global_settings.cfg 0/1"
    exit 1
fi

if [ ! -f $1 ]; then
    echo "Global config file doesn't exist"
    exit 1
else
    source $1
fi

isTrain=$2

#########################################
######## duration config file ###########
#########################################

duration_config_file=conf/duration_${Voice}.conf
acoustic_config_file=conf/acoustic_${Voice}.conf

if [ $isTrain -eq 0 ]; then
    duration_config_file=conf/test_dur_synth_${Voice}.conf
    acoustic_config_file=conf/test_synth_${Voice}.conf
fi

echo "[DEFAULT]" > $duration_config_file 

echo "" >> $duration_config_file
echo "Merlin: $MerlinDir" >> $duration_config_file

echo "" >> $duration_config_file
echo "TOPLEVEL: $WorkDir" >> $duration_config_file

echo "" >> $duration_config_file
echo "[Paths]" >> $duration_config_file

echo "" >> $duration_config_file
echo "# where to place work files" >> $duration_config_file
echo "work: %(TOPLEVEL)s/experiments/${Voice}/duration_model" >> $duration_config_file 

echo "" >> $duration_config_file
echo "# where to find the data" >> $duration_config_file
echo "data: %(work)s/data" >> $duration_config_file

echo "" >> $duration_config_file
echo "# list of file basenames, training and validation in a single list" >> $duration_config_file
echo "file_id_list: %(data)s/${FileIDList}" >> $duration_config_file
if [ $isTrain -eq 0 ]; then
    echo "test_id_list: %(TOPLEVEL)s/experiments/${Voice}/test_synthesis/test_id_list.scp" >> $duration_config_file
fi

echo "" >> $duration_config_file
echo "# output duration features" >> $duration_config_file 
echo "in_dur_dir: %(data)s/dur" >> $duration_config_file

echo "" >> $duration_config_file
echo "# where to save log" >> $duration_config_file
echo "log_path: %(work)s/log" >> $duration_config_file

echo "" >> $duration_config_file
echo "# where to save plots" >> $duration_config_file
echo "plot: %(work)s/plots" >> $duration_config_file

echo "" >> $duration_config_file
echo "# logging" >> $duration_config_file
echo "log_config_file: %(TOPLEVEL)s/conf/logging_config.conf" >> $duration_config_file
echo "log_file: %(work)s/log/mylogfilename.log" >> $duration_config_file

echo "" >> $duration_config_file
echo "[Labels]" >> $duration_config_file

echo "" >> $duration_config_file
echo "silence_pattern : ['*-sil+*']" >> $duration_config_file
echo "label_type : ${Labels}" >> $duration_config_file
echo "label_style: cppmary" >> $duration_config_file
if [ $isTrain -gt 0 ]; then
    echo "label_align: %(TOPLEVEL)s/experiments/${Voice}/duration_model/data/lab" >> $duration_config_file
else
    echo "label_align: %(TOPLEVEL)s/experiments/${Voice}/test_synthesis/prompt-lab" >> $duration_config_file
fi

echo "question_file_name  : %(Merlin)s/misc/questions/${QuestionFile}" >> $duration_config_file

echo "" >> $duration_config_file
echo "add_frame_features    : False" >> $duration_config_file

echo "" >> $duration_config_file
echo "# options: state_only, none" >> $duration_config_file
echo "subphone_feats        : none" >> $duration_config_file

echo "" >> $duration_config_file
echo "" >> $duration_config_file
echo "[Outputs]" >> $duration_config_file
if [ "$Labels" == "state_align" ]
then
echo "dur    : 5" >> $duration_config_file
elif [ "$Labels" == "phone_align" ]
then
echo "dur    : 1" >> $duration_config_file
else
    echo "These labels ($Lables) are not supported as of now...please use state_align or phone_align!!"
fi

if [ $isTrain -eq 0 ]; then
    echo "" >> $duration_config_file
    echo "[Waveform]" >> $duration_config_file
    echo "" >> $duration_config_file
    echo "test_synth_dir :  %(TOPLEVEL)s/experiments/${Voice}/test_synthesis/gen-lab" >> $duration_config_file
fi

echo "" >> $duration_config_file
echo "[Architecture]" >> $duration_config_file
echo "hidden_layer_size  : [1024, 1024, 1024, 1024, 1024, 1024]" >> $duration_config_file
echo "hidden_layer_type  : ['TANH', 'TANH', 'TANH', 'TANH', 'TANH', 'TANH']" >> $duration_config_file

echo "#if RNN or sequential training is used, please set sequential_training to True." >> $duration_config_file
echo "sequential_training : False" >> $duration_config_file
echo "dropout_rate : 0.0" >> $duration_config_file

echo "" >> $duration_config_file
echo "learning_rate    : 0.002" >> $duration_config_file
echo "batch_size       : ${duration_batch_size}" >> $duration_config_file
echo "output_activation: linear" >> $duration_config_file
echo "warmup_epoch     : 10" >> $duration_config_file
echo "warmup_momentum  : 0.3" >> $duration_config_file

echo "" >> $duration_config_file
echo "training_epochs  : ${epoch_num}" >> $duration_config_file
echo "lab_dim : ${duration_lab_dim}" >> $duration_config_file
echo "hidden_dim : ${duration_hidden_dim}" >> $duration_config_file
echo "model_prefix : ${duration_model_prefix}" >> $duration_config_file
echo "pretrain_prefix : ${pretrain_duration_model_prefix}" >> $duration_config_file



echo "" >> $duration_config_file
echo "[Streams]" >> $duration_config_file
echo "# which feature to be used in the output" >> $duration_config_file
echo "output_features      : ['dur']" >> $duration_config_file

echo "" >> $duration_config_file
echo "" >> $duration_config_file
echo "[Data]" >> $duration_config_file
echo "#buffer size of each block of data to" >> $duration_config_file
echo "buffer_size: 200000" >> $duration_config_file

echo "" >> $duration_config_file
echo "" >> $duration_config_file
echo "[Processes]" >> $duration_config_file

if [ $isTrain -gt 0 ]; then
    echo "" >> $duration_config_file
    echo "# Main processes" >> $duration_config_file
    echo "" >> $duration_config_file
    echo "DurationModel : True" >> $duration_config_file
    echo "framework : ${framework}" >> $duration_config_file
    echo "" >> $duration_config_file
    echo "# sub-processes" >> $duration_config_file
    echo "" >> $duration_config_file
    if [ $prepare_data -eq 0 ]; then
        echo "NORMLAB  : False" >> $duration_config_file
        echo "MAKEDUR  : False" >> $duration_config_file
        echo "MAKECMP  : False" >> $duration_config_file
        echo "NORMCMP  : False" >> $duration_config_file
    else
        echo "NORMLAB  : True" >> $duration_config_file
        echo "MAKEDUR  : True" >> $duration_config_file
        echo "MAKECMP  : True" >> $duration_config_file
        echo "NORMCMP  : True" >> $duration_config_file
    fi
    echo "" >> $duration_config_file
    echo "TRAINDNN : True" >> $duration_config_file
    echo "DNNGEN   : True" >> $duration_config_file
    echo "" >> $duration_config_file
    echo "CALMCD   : True" >> $duration_config_file
    echo "" >> $duration_config_file
    echo "" >> $duration_config_file
    echo "Duration configuration settings stored in $duration_config_file"
else
    echo "" >> $duration_config_file
    echo "# Main processes" >> $duration_config_file
    echo "" >> $duration_config_file
    echo "DurationModel : True" >> $duration_config_file
    echo "framework : ${framework}" >> $duration_config_file
    echo "GenTestList   : True" >> $duration_config_file
    echo "" >> $duration_config_file
    echo "# sub-processes" >> $duration_config_file
    echo "" >> $duration_config_file
    echo "NORMLAB  : True" >> $duration_config_file
    echo "" >> $duration_config_file
    echo "DNNGEN   : True" >> $duration_config_file
    echo "" >> $duration_config_file
    echo "" >> $duration_config_file
    echo "Duration configuration settings stored in $duration_config_file"
fi

#########################################
######## acoustic config file ###########
#########################################

echo "[DEFAULT]" > $acoustic_config_file

echo "" >> $acoustic_config_file
echo "Merlin: $MerlinDir" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "TOPLEVEL: ${WorkDir}" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "[Paths]" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "# where to place work files" >> $acoustic_config_file
echo "work: %(TOPLEVEL)s/experiments/${Voice}/acoustic_model" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "# where to find the data" >> $acoustic_config_file
echo "data: %(work)s/data" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "# list of file basenames, training and validation in a single list" >> $acoustic_config_file
echo "file_id_list: %(data)s/${FileIDList}" >> $acoustic_config_file
if [ $isTrain -eq 0 ]; then
    echo "test_id_list: %(TOPLEVEL)s/experiments/${Voice}/test_synthesis/test_id_list.scp" >> $acoustic_config_file
fi

echo "" >> $acoustic_config_file
echo "" >> $acoustic_config_file
echo "in_mgc_dir: %(data)s/mgc" >> $acoustic_config_file
echo "in_bap_dir: %(data)s/bap" >> $acoustic_config_file
echo "in_lf0_dir: %(data)s/lf0" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "# where to save log" >> $acoustic_config_file
echo "log_path: %(work)s/log" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "# where to save plots" >> $acoustic_config_file
echo "plot: %(work)s/plots" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "# logging" >> $acoustic_config_file
echo "log_config_file: %(TOPLEVEL)s/conf/logging_config.conf" >> $acoustic_config_file
echo "log_file: %(work)s/log/mylogfilename.log" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "# where are my tools" >> $acoustic_config_file
echo "sptk:  %(Merlin)s/tools/bin/SPTK-3.9/" >> $acoustic_config_file
echo "mlsa:  %(Merlin)s/tools/mlsa/" >> $acoustic_config_file

if [ "$Vocoder" == "STRAIGHT" ]
then
    echo "straight :%(Merlin)s/tools/straight/bin" >> $acoustic_config_file
elif [ "$Vocoder" == "WORLD" ]
then
    echo "world: %(Merlin)s/tools/bin/WORLD" >> $acoustic_config_file
else
    echo "This vocoder ($Vocoder) is not supported as of now...please configure yourself!!"
fi

echo "" >> $acoustic_config_file
echo "[Labels]" >> $acoustic_config_file

echo "" >> $acoustic_config_file
if [ $isTrain -eq 0 ]; then
    echo "enforce_silence : True" >> $acoustic_config_file
fi
echo "silence_pattern : ['*-sil+*']" >> $acoustic_config_file
echo "label_type : ${Labels}" >> $acoustic_config_file
echo "label_style: cppmary" >> $acoustic_config_file
if [ $isTrain -gt 0 ]; then
    echo "label_align: %(TOPLEVEL)s/experiments/${Voice}/acoustic_model/data/lab" >> $acoustic_config_file
else
    echo "label_align: %(TOPLEVEL)s/experiments/${Voice}/test_synthesis/gen-lab" >> $acoustic_config_file
fi
echo "question_file_name  : %(Merlin)s/misc/questions/${QuestionFile}" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "add_frame_features    : True" >> $acoustic_config_file

echo "" >> $acoustic_config_file
if [ "$Labels" == "state_align" ]
then
echo "# options: full, coarse_coding, minimal_frame, state_only, frame_only, none" >> $acoustic_config_file
echo "subphone_feats        : full" >> $acoustic_config_file
elif [ "$Labels" == "phone_align" ]
then
echo "# options: coarse_coding, minimal_phoneme, none" >> $acoustic_config_file
echo "subphone_feats        : coarse_coding" >> $acoustic_config_file
else
    echo "These labels ($Lables) are not supported as of now...please use state_align or phone_align!!"
fi

echo "" >> $acoustic_config_file
echo "" >> $acoustic_config_file
echo "[Outputs]" >> $acoustic_config_file

echo "mgc    : ${mgc_order}" >> $acoustic_config_file
echo "dmgc   : $(($mgc_order * 3))" >> $acoustic_config_file
echo "bap    : ${bap_order}" >> $acoustic_config_file
echo "dbap   : $(($bap_order * 3))" >> $acoustic_config_file
echo "lf0    : 1" >> $acoustic_config_file
echo "dlf0   : 3" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "[Waveform]" >> $acoustic_config_file

if [ $isTrain -eq 0 ]; then
    echo "" >> $acoustic_config_file
    echo "test_synth_dir :  %(TOPLEVEL)s/experiments/${Voice}/test_synthesis/wav" >> $acoustic_config_file
fi

echo "" >> $acoustic_config_file
echo "vocoder_type : ${Vocoder}" >> $acoustic_config_file

if [ "$SamplingFreq" == "16000" ]
then
    echo "samplerate : 16000" >> $acoustic_config_file
    echo "framelength : 1024" >> $acoustic_config_file
    echo "fw_alpha : 0.58" >> $acoustic_config_file
    echo "minimum_phase_order : 511" >> $acoustic_config_file
elif [ "$SamplingFreq" == "48000" ]
then
    echo "samplerate : 48000" >> $acoustic_config_file
    if [ "$Vocoder" == "WORLD" ]
    then
        echo "framelength : 2048" >> $acoustic_config_file
        echo "minimum_phase_order : 1023" >> $acoustic_config_file
    else
        echo "framelength : 4096" >> $acoustic_config_file
        echo "minimum_phase_order : 2047" >> $acoustic_config_file
    fi
    echo "fw_alpha : 0.77" >> $acoustic_config_file
else
    echo "This sampling frequency ($SamplingFreq) never tested before...please configure yourself!!"
fi

echo "" >> $acoustic_config_file
echo "[Architecture]" >> $acoustic_config_file

echo "hidden_layer_size  : [1024, 1024, 1024, 1024, 1024, 1024]" >> $acoustic_config_file
echo "hidden_layer_type  : ['TANH', 'TANH', 'TANH', 'TANH', 'TANH', 'TANH']" >> $acoustic_config_file

echo "#if RNN or sequential training is used, please set sequential_training to True." >> $acoustic_config_file
echo "sequential_training : False" >> $acoustic_config_file
echo "dropout_rate : 0.0" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "learning_rate    : 0.002" >> $acoustic_config_file
echo "batch_size       : ${acoustic_batch_size}" >> $acoustic_config_file
echo "output_activation: linear" >> $acoustic_config_file
echo "warmup_epoch     : 10" >> $acoustic_config_file
echo "warmup_momentum  : 0.3" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "training_epochs  : ${epoch_num}" >> $acoustic_config_file
echo "lab_dim : ${acoustic_lab_dim}" >> $acoustic_config_file
echo "hidden_dim : ${acoustic_hidden_dim}" >> $acoustic_config_file
echo "model_prefix : ${acoustic_model_prefix}" >> $acoustic_config_file
echo "pretrain_prefix : ${pretrain_acoustic_model_prefix}" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "[Streams]" >> $acoustic_config_file
echo "# which feature to be used in the output" >> $acoustic_config_file
echo "output_features      : ['mgc', 'lf0', 'vuv', 'bap']" >> $acoustic_config_file
if [ $isTrain -eq 0 ]; then
    echo "gen_wav_features     : ['mgc', 'lf0', 'bap']" >> $acoustic_config_file
fi

echo "" >> $acoustic_config_file
echo "" >> $acoustic_config_file
echo "[Data]" >> $acoustic_config_file
echo "#buffer size of each block of data to" >> $acoustic_config_file
echo "buffer_size: 200000" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "" >> $acoustic_config_file
echo "[Processes]" >> $acoustic_config_file

echo "" >> $acoustic_config_file
echo "# Main processes" >> $acoustic_config_file

if [ $isTrain -gt 0 ]; then
    echo "" >> $acoustic_config_file
    echo "AcousticModel : True" >> $acoustic_config_file
    echo "framework : ${framework}" >> $acoustic_config_file
    echo "" >> $acoustic_config_file
    echo "# sub-processes" >> $acoustic_config_file
    echo "" >> $acoustic_config_file
    if [ $prepare_data -eq 0 ]; then
        echo "NORMLAB  : False" >> $acoustic_config_file
        echo "MAKECMP  : False" >> $acoustic_config_file
        echo "NORMCMP  : False" >> $acoustic_config_file
    else
        echo "NORMLAB  : True" >> $acoustic_config_file
        if [ $prepare_cmp -eq 0 ]; then
            echo "MAKECMP  : False" >> $acoustic_config_file
            echo "NORMCMP  : False" >> $acoustic_config_file
        else
            echo "MAKECMP  : True" >> $acoustic_config_file
            echo "NORMCMP  : True" >> $acoustic_config_file
        fi
    fi
    echo "" >> $acoustic_config_file
    echo "TRAINDNN : True" >> $acoustic_config_file
    echo "DNNGEN   : True" >> $acoustic_config_file
    echo "" >> $acoustic_config_file
    echo "GENWAV   : True" >> $acoustic_config_file
    echo "CALMCD   : True" >> $acoustic_config_file
    echo "" >> $acoustic_config_file
    echo "" >> $acoustic_config_file
    echo "Acoustic configuration settings stored in $acoustic_config_file"
else
    echo "" >> $acoustic_config_file
    echo "AcousticModel : True" >> $acoustic_config_file
    echo "framework : ${framework}" >> $acoustic_config_file
    echo "GenTestList   : True" >> $acoustic_config_file
    echo "" >> $acoustic_config_file
    echo "# sub-processes" >> $acoustic_config_file
    echo "" >> $acoustic_config_file
    echo "NORMLAB  : True" >> $acoustic_config_file
    echo "" >> $acoustic_config_file
    echo "DNNGEN   : True" >> $acoustic_config_file
    echo "" >> $acoustic_config_file
    echo "GENWAV   : True" >> $acoustic_config_file
    echo "" >> $acoustic_config_file
    echo "" >> $acoustic_config_file
    echo "Acoustic configuration settings stored in $acoustic_config_file"
fi

