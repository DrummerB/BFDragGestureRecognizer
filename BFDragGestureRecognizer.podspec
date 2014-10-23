Pod::Spec.new do |s|
  s.name        = 'BFDragGestureRecognizer'
  s.version     = '1.1.0'
  s.platform    = :ios
  s.license     = { :type => 'BSD', :file => 'LICENSE' }
  s.homepage    = 'https://github.com/DrummerB/BFDragGestureRecognizer'
  s.authors     = { 'Balazs Faludi' => 'balazsfaludi@gmail.com' }
  s.screenshot  = 'http://i.imgur.com/3gmX3VG.png'
  s.summary     = 'A UIGestureRecognizer subclass that can be used to drag views inside a scroll view with automatic scrolling at the edges of the scroll view.'
  s.description = <<-DESC
                  A UIGestureRecognizer subclass that can be used to drag 
                  views inside a scroll view with automatic scrolling at
                  the edges of the scroll view.
                  DESC
  s.source    = { 
    :git => "https://github.com/DrummerB/BFDragGestureRecognizer.git",
    :tag =>  s.version.to_s
  }

  s.source_files  = 'BFDragGestureRecognizer/*.{h,m}'
  
  s.requires_arc = true

end
