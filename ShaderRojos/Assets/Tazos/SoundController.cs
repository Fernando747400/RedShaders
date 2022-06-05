using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundController : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] private bool _playMusic;
    [SerializeField] private bool _playSFX;

    [Header("AudioClips")]
    [SerializeField] private AudioClip _music;
    [SerializeField] private AudioClip _OpenBag;

    private AudioSource _audioSource;
    private bool _canPlayMusic = false;
    private bool _canPlaySFX = false;

    private void Start()
    {
        _audioSource = this.GetComponent<AudioSource>();
        _audioSource.clip = _music;
    }

    public void PlaySFX()
    {
        if(_canPlaySFX) _audioSource.PlayOneShot(_OpenBag, 0.8f);
    }

    public void PlayMusic()
    {
        if (_canPlayMusic)
        {
            _audioSource.Play();
        }
        else
        {
            _audioSource.Stop();
        }
       
    }

    public void ToggleMusic()
    {
        _canPlayMusic = !_canPlayMusic;
    }

    public void ToggleSFX()
    {
        _canPlaySFX = !_canPlaySFX;
    }


}
